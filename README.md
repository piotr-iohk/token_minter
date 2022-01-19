## Token Minter

Mint tokens on testnets or mainnet from a payment address and send them directly to your address.

Running this scripts requires `cardano-node` running on your machine. 

### How to use it

1. If needed adjust settings in `env.rb`. (Probably you don't have to as all settings can be passed as env variables).

2. Create policy script and payment address:
```
export POLICY_DIR=happy_coin
rake create_policy_script
rake create_payment_addr
```

3. Fund payment address from the faucet. (This is the address from which tokens will be minted)
Note that single mint tx that sends tokens to your wallet will cost ~1.8 ADA.

4. Mint some tokens.

First set the destination address your tokens will be sent to:
```
export DEST_ADDRESS=addr_test1qpm62kuf96dz70cjch9twczycnalyvm4zwegs2rxfa3d6qgw4q8hcawcad3gyt87fnw5zc0xq92dsewmse4afgxkg96skqvcen
```

Mint multiple tokens in single transaction:
```
# 1 tx with 100000 of HappyCoin

rake mint[1,100000,HappyCoin,1]
```

Mint 1 token per transaction (NFTs):
```
# 5 txs each minting only 1 token with asset name: NFTx0, NFTx1...etc.

rake mint[5,1,NFTx]
```

### Limitations
 - payment address needs to have only one utxo
 - tokens are minted from single utxo therefore the script waits until previous minting tx is done
