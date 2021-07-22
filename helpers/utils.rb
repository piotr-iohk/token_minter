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
  end
end
