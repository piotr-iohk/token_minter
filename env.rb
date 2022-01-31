require_relative 'helpers/utils'
require_relative 'helpers/minter'

##
# These can be set via Env variables, if not default values will be assigned
ENV['NETWORK'] ||= "testnet" # mainnet | testnet | alonzo-white | shelley_qa
ENV['CARDANO_NODE_SOCKET_PATH'] ||= "/home/piotr/t/node/relay1/node.socket"
ENV['POLICY_DIR'] ||= "instruments"

NETWORK = ENV['NETWORK']
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
