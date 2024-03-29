def log(text)
  puts "#{Time.now} - #{text}"
end

def cmd(cmd)
  log cmd.gsub(/\s+/, ' ')
  res = `#{cmd}`
  log res
  res
end

def network_param
  case NETWORK
  when 'testnet'
    '--testnet-magic 1097911063'
  when 'mainnet'
    '--mainnet'
  when 'alonzo-white'
    '--testnet-magic 7'
  when 'alonzo-purple'
    '--testnet-magic 8'
  when 'shelley_qa'
    '--testnet-magic 3'
  when 'vasil-dev', 'vasil-qa'
    '--testnet-magic 9'
  when 'preview'
    '--testnet-magic 2'
  when 'preprod'
    '--testnet-magic 1'
  end
end
