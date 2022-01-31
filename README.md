
## Token Minter

Mint tokens on testnets or mainnet from a payment address and send them directly to preferred destination address.

Running this scripts requires `cardano-node` running on your machine.

### Ruby env set up
1. Clone this repository `git clone https://github.com/piotr-iohk/token_minter.git`
2. Install ruby (https://www.ruby-lang.org/en/documentation/installation/).

E.g. for Ubuntu:
```bash
$ sudo apt-get install ruby-full
```
For Windows there is an installer (https://www.ruby-lang.org/en/documentation/installation/#rubyinstaller).

3. Install dependencies
```bash
$ cd token_minter
$ bundle install
```
 > ℹ️ _if installing dependencies fails you may have to install `bundler` before_
```bash
$ gem install bundler
```

### How to use it

1. Adjust settings in `env.rb`. (All settings can be passed also as env variables).

```ruby
##
# These can be set via Env variables, if not default values will be assigned
ENV['NETWORK'] ||= "testnet" # mainnet | testnet | alonzo-white | shelley_qa
ENV['CARDANO_NODE_SOCKET_PATH'] ||= "/home/piotr/t/node/relay1/node.socket"
ENV['POLICY_DIR'] ||= "instruments"
```
 - NETWORK - we will be minting on this particular network. It will create a context sub-dir to hold all the needed files there. Location: `fixtures/$NETWORK`.
 - CARDANO_NODE_SOCKET_PATH - absolute path to the socket path of the your local cardano-node instance. (On Windows it is a path to named pipe used by the node)
 - POLICY_DIR - directory that will hold all the helper files (policy script, payment address from which we will be minting, generated metadata file). Location: `fixtures/$NETWORK/$POLICY_DIR`.

2. Create policy script and payment address:
```bash
$ rake create_policy_script
$ rake create_payment_addr
```
Files will be created in the `fixtures/$NETWORK/$POLICY_DIR`.

3. Fund payment address from the faucet. (This is the address from which tokens will be minted)
Note that single mint tx that sends tokens to your wallet will cost ~1.5 ADA.

4. Mint some tokens.

 > ℹ️ Before minting you may want to adjust metadata that will be generated in the minting transaction in the [minter.rb](https://github.com/piotr-iohk/token_minter/blob/master/helpers/minter.rb#L11-L22). 

First set the destination address your tokens will be sent to:
```bash
$ export DEST_ADDRESS=addr_test1qpm62kuf96dz70cjch9twczycnalyvm4zwegs2rxfa3d6qgw4q8hcawcad3gyt87fnw5zc0xq92dsewmse4afgxkg96skqvcen
```

Mint multiple tokens in single transaction:
```bash
# 1 tx with 100000 of HappyCoin

$ rake mint[1,100000,HappyCoin]
```

Mint 1 token per transaction (NFTs):
```bash
# 5 txs each minting only 1 token with incremented asset name: NFTx0, NFTx1...etc.

$ rake mint[5,1,NFTx,+]
```

### Limitations
 - payment address needs to have only one utxo
 - tokens are minted from single utxo therefore the script waits until previous minting tx is done
