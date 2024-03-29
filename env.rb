require_relative 'helpers/utils'
require_relative 'helpers/minter'

##
# These can be set via Env variables, if not default values will be assigned
ENV['NETWORK'] ||= "preprod" # mainnet | testnet | alonzo-white | shelley_qa | vasil-dev | preview | preprod
ENV['ERA'] ||= "Babbage" # Mary | Alonzo | Babbage etc. name of the era the node is at
ENV['CARDANO_NODE_SOCKET_PATH'] = "/home/piotr/.cardano-up/state/0/preprod/node.socket"
ENV['POLICY_DIR'] ||= "native_test"

NETWORK = ENV['NETWORK']
ERA = ENV['ERA'].downcase
CARDANO_NODE_SOCKET_PATH = ENV['CARDANO_NODE_SOCKET_PATH']
POLICY_DIR = ENV['POLICY_DIR']
DEST_ADDRESS = ENV['DEST_ADDRESS']
###

##
# Don't worry about these
ENV['CARDANO_NODE_SOCKET_PATH'] = CARDANO_NODE_SOCKET_PATH
CONTEXT = "fixtures/#{NETWORK}"
TIMEOUT = 120
###
