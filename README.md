# Oracles Presale Contract
[![Build Status](https://travis-ci.org/rstormsf/oracles-presale.svg?branch=master)](https://travis-ci.org/rstormsf/oracles-presale)
[![Coverage Status](https://coveralls.io/repos/github/rstormsf/oracles-presale/badge.svg?branch=master)](https://coveralls.io/github/rstormsf/oracles-presale?branch=master)

[Full Test Report](https://rstormsf.github.io/oracles-presale/mochawesome.html)
Presale contract that records investor's balances and sends ether to presale owner.
It allows to set minimum Contrubution amount, start Date, end Date.

To use:
1. Flat [contracts/PresaleOracles.sol](contracts/PresaleOracles.sol) by using [solidity-flattener](https://github.com/BlockCatIO/solidity-flattener)
```
solidity_flattener --solc-paths=zeppelin-solidity=$(pwd)/node_modules/zeppelin-solidity/ contracts/PresaleOracles.sol --out flat/PresaleOracles_flat.sol
```
2. Deploy [flat file](flat/PresaleOracles_flat.sol)
3. Call `initialize` with following params:

    -startTime in unix format 

    -endTime in unix format 

    -cap in wei format 

    -minimumContribution in wei format

    -vault (eth address where funds will be collected) 
    
Example: 

    "1510291574","1610291574","100000000000000000000","100000000000000000","0x0039f22efb07a647557c7c5d17854cfd6d489ef3"
    startTime: `Friday, November 10, 2017 5:26:14 AM `
    endTime: `Sunday, January 10, 2021 3:12:54 PM `
    cap: `100 eth `
    minimum: `0.1 eth `
    vault: `0x0039f22efb07a647557c7c5d17854cfd6d489ef3`
4. Whitelist investors by calling `whitelistInvestors` with an array ['0x0039f22efb07a647557c7c5d17854cfd6d489ef3']
5. Let whitelisted investors send money to contract's address OR to send to `buy` method (`0xa6f2ae3a`)

# How to whitelist a lot of addresses in batch
1. `cd scripts`
2. `npm install`
3. open `.env` file and modify settings:
```
PRESALE_ADDRESS=0x6F3f79941f89E03D4aF9bDb8BE0623DC24F2bef0
UNLOCKED_ADDRESS=0x0039f22efb07a647557c7c5d17854cfd6d489ef3
RPC_PORT=8549
GAS_PRICE=0.7
```
4. run parity with unlocked account from which the deployment will happen. It has to match with your .env UNLOCKED_ADDRESS:
```
parity --jsonrpc-port 8549 --chain kovan --unlock 0x0039F22efB07A647557C7C5d17854CFD6D489eF3 --password $HOME/FILE_PATH_TO_YOUR_PASSWORD_FILE
```
5. Copy list of addresses into [scripts/ARRAY_OF_ADDRESSES.json](scripts/ARRAY_OF_ADDRESSES.json)
5. run `node whitelist.js`

# Test result and gas usage
```

  Contract: Presale
    ✓ constructor should set owner
    ✓ can not buy if not initialized (21411 gas)
    #initilize
      ✓ rejects if not sent by owner (25424 gas)
      ✓ sets values (131614 gas)
      ✓ cannot initialize twice (157350 gas)
      ✓ startTime cannot be 0 (25168 gas)
      ✓ endTime cannot be 0 (25232 gas)
      ✓ endTime cannot be less than startTime (25424 gas)
      ✓ cap cannot be 0 (24976 gas)
      ✓ vault cannot be 0x0 (24144 gas)
      ✓ minimumContribution cannot be 0 (24976 gas)
    #buy
      ✓ cannot buy if not whitelisted (21411 gas)
      ✓ cannot buy if not value is 0 (63333 gas)
      ✓ cannot buy if not value is less than minimum (63333 gas)
      ✓ can not buy if time is not within startTime&endTime (111666 gas)
      ✓ can not buy more than cap (63333 gas)
      ✓ happy path (244544 gas)
    whitelisting capabilities
      #whitelistInvestor
        ✓ cannot by called by non-owner (23450 gas)
        ✓ whitelists an investor (64399 gas)
      #whitelistInvestors
        ✓ cannot by called by non-owner (23666 gas)
        ✓ whitelists investors (119844 gas)
      #blacklistInvestor
        ✓ cannot by called by non-owner (23582 gas)
        ✓ blacklist an investors (139579 gas)

·------------------------------------------------------------------------|-----------------------------------·
│                                  Gas                                   ·  Block limit: 17592186044415 gas  │
··········································|······························|····································
│  Methods                                ·          1 gwei/gas          ·          307.55 usd/eth           │
···················|······················|·········|··········|·········|················|···················
│  Contract        ·  Method              ·  Min    ·  Max     ·  Avg    ·  # calls       ·  usd (avg)       │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  blacklistInvestor   ·  19735  ·   23582  ·  21659  ·             2  ·            0.01  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  buy                 ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  claimTokens         ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  initialize          ·  24144  ·  131614  ·  46431  ·            10  ·            0.01  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  Presale             ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  transferOwnership   ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  whitelistInvestor   ·  23450  ·   64399  ·  50749  ·             3  ·            0.02  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  whitelistInvestors  ·  23666  ·  119844  ·  87785  ·             3  ·            0.03  │
·------------------|----------------------|---------|----------|---------|----------------|------------------·

  23 passing (3m)
```
# Testnet deployment

=====
## Latest Contract deployment
https://kovan.etherscan.io/address/0x6f3f79941f89e03d4af9bdb8be0623dc24f2bef0
=====

## Previous deployments with old source code:

Contract Deployment: https://kovan.etherscan.io/address/0xb9b49e21e77d2d89a9e4c7ef4f684ad2a4e99663#code

Called Initialize by Owner with params: 
"1510291574","1610291574","40000000000000000000000","1000000000000000000","0x0039f22efb07a647557c7c5d17854cfd6d489ef3"
(40000 eth cap, 1 eth minimum)
https://kovan.etherscan.io/tx/0xc95047493d8eead08c3bef52c54cc2ffcbd2e0ef89c1ba1a719d28bd98011c84

Called fallback with 0.5 ether: (expected error)
https://kovan.etherscan.io/tx/0x6f7335f55257a56f9382d47dfeacf26e482f3c6238e829dfbc5e143d6972f0e0

Called buy(`0xa6f2ae3a`) with 1 ether:
https://kovan.etherscan.io/tx/0xdbf29ed04dcb1a71e90f3a404739b6e3bb2c526b7788547ad9dc66e5eb64c79f
Verified forwarded funds as internal transaction.

Called fallback with 0.1 ether to add to already contributer 1 eth from the same address:
https://kovan.etherscan.io/tx/0x76b38e3211ad5ce465edce69faf0d69837b924e47f705ec16cf4e30fc163781e

Cap tests:
Deployed contract: https://kovan.etherscan.io/address/0x9acf295c782e14ac86b87a3545e444256a3a7e56#readContract
"1510291574","1610291574","500000000000000000","100000000000000000","0x0039f22efb07a647557c7c5d17854cfd6d489ef3"
(cap 0.5 eth, min 0.1 eth)

Send 1 eth over cap(expected error):
https://kovan.etherscan.io/tx/0xb0c4a7f64bd392fae8b174a1304d91691c1cb3acdec0d290fd3a734a725cbcaa

Send 0.5 to match cap:
https://kovan.etherscan.io/tx/0x5709e2ca2b4406a89c4ecedc2f1913b7ce9cdef66670b694851650a4fe037ae2

Send additional 0.00001 to over cap(expected error):
https://kovan.etherscan.io/tx/0x826229102f3a235c21173295434507a9664ad3f822edc1b9af488bdc3f01e32d

Time tests:
Send after sale ends(expected error):
"1507667268","1507753668","500000000000000000","100000000000000000","0x0039f22efb07a647557c7c5d17854cfd6d489ef3"
https://kovan.etherscan.io/address/0xec1afb89f87cb0ac296cad6e73dbeeab5b006050#readContract

Send 0.1 ether to get rejected:
https://kovan.etherscan.io/tx/0xd859be5b5b58303a4cbc61902f8927efa9de96a3739ce39a18e1f6949a154c2b
