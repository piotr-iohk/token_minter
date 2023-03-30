require "rspec/core/rake_task"
require_relative 'env'


include Minter

RSpec::Core::RakeTask.new(:spec)

##
# create payment address (address from which minting will be done)
# address and keys will be in CONTEXT/POLICY_DIR/payment.*
task :create_payment_addr do |t, args|
  raise "POLICY_DIR is not set" if POLICY_DIR.empty?

  ma_dir = "#{CONTEXT}/#{POLICY_DIR}"
  FileUtils.mkdir_p(ma_dir)

  # create keys
  cmd %(cardano-cli  address key-gen \
         --verification-key-file #{ma_dir}/payment.vkey \
         --signing-key-file #{ma_dir}/payment.skey)

  # generate address
  cmd %(cardano-cli address build \
         --payment-verification-key-file #{ma_dir}/payment.vkey \
         --out-file #{ma_dir}/payment.addr \
         #{network_param})
  puts "Payment address created..."
  include Minter
  puts get_payment_addr
  cli_query_utxo
end

task :check_payment_addr do |t, args|
  raise "POLICY_DIR is not set" if POLICY_DIR.empty?

  include Minter
  puts get_payment_addr
  get_all_utxos
end

##
# create policy script and keys in CONTEXT/policy_dir/policy.*
task :create_policy_script do |t, args|
  raise "POLICY_DIR is not set" if POLICY_DIR.empty?

  ma_dir = "#{CONTEXT}/#{POLICY_DIR}"
  FileUtils.mkdir_p(ma_dir)

  # Create policy script
  cmd %(cardano-cli address key-gen \
        --verification-key-file #{ma_dir}/policy.vkey \
        --signing-key-file #{ma_dir}/policy.skey)
  keyhash = cmd(%(cardano-cli address key-hash --payment-verification-key-file #{ma_dir}/policy.vkey)).gsub("\n", '')

  script = %({
       "type": "all",
       "scripts": [
         {
           "type": "sig",
           "keyHash": "#{keyhash}"
         }
       ]
   })
  puts script

  File.open("#{ma_dir}/policy.script", "w") do |f|
    f.write(script)
  end
  policy_id = cmd("cardano-cli transaction policyid --script-file #{ma_dir}/policy.script").gsub("\n", '')
  puts "Policy ID: #{policy_id}"
  # ----------------------------
end

##
# Minting a token and sending to wallet address picked randomly
# e.g. rake mint[1,1500,HappyCoin] - 1 tx minting 1500 of HappyCoin
#      rake mint[5,1,NFTx,+] - 5 txs each minting 1 token named NFTx0, NFTx1...etc.
task :mint, [:num_of_txs, :tokens_amt_per_tx, :asset_name_prefix, :increment] do |_, args|
  num_of_txs = args[:num_of_txs].to_i # how many mint transactions
  tokens_amt_per_tx = args[:tokens_amt_per_tx].to_i # amount to be minted in each tx
  asset_name_prefix = args[:asset_name_prefix] # asset name prefix
  increment = args[:increment] || '~' # if increment = '+' all have asset_nameN (where N is incremented from 0)
  log "---"
  log "Minting #{num_of_txs} times of an '#{asset_name_prefix}' and sending to address: #{DEST_ADDRESS}"
  log "---"

  # ----------------------------

  num_of_txs.times do |i|
    dest_address = DEST_ADDRESS
    asset_name = (increment == '+') ? "#{asset_name_prefix}#{i}" : asset_name_prefix
    mint_and_send(asset_name, dest_address, tokens_amt_per_tx)
  end

end
