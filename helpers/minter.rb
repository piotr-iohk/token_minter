
module Minter
  def get_payment_addr
      File.read("#{CONTEXT}/#{POLICY_DIR}/payment.addr")
  end

  def get_policy_id
    cmd("cardano-cli transaction policyid --script-file #{CONTEXT}/#{POLICY_DIR}/policy.script").gsub("\n", '')
  end

  def get_mint_metadata(policy_id, asset_name)
    %({
      "721": {
        "#{policy_id}": {
          "#{asset_name}": {
            "name": "Test NFT ##{asset_name}",
            "image": "ipfs://XXXXYYYYZZZZ"
          }
        }
      }
    })
  end

  def create_metadata(asset_name)
    log "Creating metadata for #{asset_name}"
    policy_id = get_policy_id
    m = get_mint_metadata(policy_id, asset_name)

    File.open("#{CONTEXT}/#{POLICY_DIR}/metadata.json", "w") do |f|
      f.write(m)
    end

    "#{CONTEXT}/#{POLICY_DIR}/metadata.json"
  end

  ##
  # gets address' last utxo, ix, and amount
  def cli_query_utxo
    res = cmd %(cardano-cli query utxo \
                 --address #{get_payment_addr} \
                 #{network_param})

     # [utxo, ix, amount ...]
     res.split("\n").last.split(" ")
  end

  def get_all_utxos
    res = cmd %(cardano-cli query utxo \
                 --address #{get_payment_addr} \
                 #{network_param})
    res.split('-' * 86).last.split("\n").map do |line|
      line.split(" ")
    end.filter { |x| x.length > 0}
    # [
    #   [utxo, ix, amount ...],
    #   [utxo, ix, amount ...],
    #   [utxo, ix, amount ...] 
    # ]
  end

  def cli_build_tx(utxos, out_address, asset_name, mint_amount = 1)
    min_utxo_value = 1500000
    policy_id = get_policy_id
    asset_id = asset_name ? "#{policy_id}.#{asset_name.unpack("H*").first}" : policy_id
    puts "ASSET ID: #{asset_id}"

    inputs = utxos.map do |utxo, ix, _|
      "--tx-in #{utxo}##{ix}"
    end.join(" ")

    cmd %(cardano-cli transaction build \
            --#{ERA}-era \
            #{network_param} \
            #{inputs} \
            --change-address="#{get_payment_addr}" \
            --tx-out="#{out_address}+#{min_utxo_value}+#{mint_amount} #{asset_id}" \
            --mint="#{mint_amount} #{asset_id}" \
            --metadata-json-file #{CONTEXT}/#{POLICY_DIR}/metadata.json \
            --mint-script-file #{CONTEXT}/#{POLICY_DIR}/policy.script \
            --witness-override 2 \
            --out-file #{CONTEXT}/#{POLICY_DIR}/tx.txbody)
  end

  def get_protocol_json
    protocol_json_file = "#{CONTEXT}/protocol.json"
    if not (File.exist? protocol_json_file)
      cmd %(cardano-cli query protocol-parameters \
             #{network_param} \
             --out-file #{protocol_json_file})
    end
    protocol_json_file
  end

  def cli_sign
    cmd %(cardano-cli transaction sign \
            --signing-key-file #{CONTEXT}/#{POLICY_DIR}/payment.skey \
            --signing-key-file #{CONTEXT}/#{POLICY_DIR}/policy.skey \
            #{network_param} \
            --tx-body-file #{CONTEXT}/#{POLICY_DIR}/tx.txbody \
            --out-file #{CONTEXT}/#{POLICY_DIR}/tx.tx)
  end

  def cli_submit
    cmd %(cardano-cli transaction submit \
          --tx-file #{CONTEXT}/#{POLICY_DIR}/tx.tx \
          #{network_param})
  end

  ##
  # Mints token and sends to out address
  # waits for utxo to change, i.e. tx in ledger
  def mint_and_send(asset_name, dest_address, mint_amount = 1)
    log "MINTING and Sending #{asset_name} to #{dest_address}"
    create_metadata(asset_name)
    utxos = get_all_utxos
    cli_build_tx(utxos, dest_address, asset_name, mint_amount)
    cli_sign
    cli_submit

    wait_for_utxo_change(utxos.first[0])
  end

  def wait_for_utxo_change(utxo)

    timeout_treshold = Time.now + TIMEOUT
    while((cli_query_utxo[0] == utxo) && (Time.now <= timeout_treshold))
      log "Waiting for utxo change on #{get_payment_addr}..."
      sleep 1
    end

    (cli_query_utxo[0] != utxo)
  end

end
