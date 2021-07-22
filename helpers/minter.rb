
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
            "name": "Test NFT ##{asset_name.split(/(\d+)/).last}",
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

    File.open("#{CONTEXT}/metadata.json", "w") do |f|
      f.write(m)
    end

    "#{CONTEXT}/metadata.json"
  end

  ##
  # gets address utxo, ix, and amount
  def cli_query_utxo
    res = cmd %(cardano-cli query utxo \
                 --address #{get_payment_addr} \
                 #{network_param})

     # [utxo, ix, amount ...]
     res.split("\n").last.split(" ")
  end

  def cli_build_raw(fee, utxo, ix, amount, out_address, asset_name, mint_amount = 1)
    min_utxo_value = 1500000
    policy_id = get_policy_id
    cmd %(cardano-cli transaction build-raw \
            --fee #{fee} \
            --tx-in #{utxo}##{ix} \
            --tx-out="#{get_payment_addr}+#{amount.to_i - fee - min_utxo_value}" \
            --tx-out="#{out_address}+#{min_utxo_value}+#{mint_amount} #{policy_id}.#{asset_name}" \
            --mint="#{mint_amount} #{policy_id}.#{asset_name}" \
            --metadata-json-file #{CONTEXT}/metadata.json \
            --mint-script-file #{CONTEXT}/#{POLICY_DIR}/policy.script \
            --out-file #{CONTEXT}/#{POLICY_DIR}/tx.txbody)
    #       --invalid-hereafter #{HEREAFTER} \
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

  def get_fee(utxo, ix, amount, out_address, asset_name)
    protocol_json_file = get_protocol_json
    cli_build_raw(1000000, utxo, ix, amount, out_address, asset_name)
    fee = cmd %(cardano-cli transaction calculate-min-fee \
                  --tx-body-file #{CONTEXT}/#{POLICY_DIR}/tx.txbody \
                  #{network_param} \
                  --protocol-params-file #{protocol_json_file} \
                  --tx-in-count 1 \
                  --tx-out-count 2 \
                  --witness-count 3)
    fee.split(' ').first.to_i
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
    utxo, ix, amount = cli_query_utxo
    fee = get_fee(utxo, ix, amount , dest_address, asset_name)
    cli_build_raw(fee, utxo, ix, amount, dest_address, asset_name, mint_amount)
    cli_sign
    cli_submit

    wait_for_utxo_change(utxo)
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
