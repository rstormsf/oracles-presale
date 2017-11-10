# Oracles Presale Contract
[![Build Status](https://travis-ci.org/rstormsf/oracles-presale.svg?branch=master)](https://travis-ci.org/rstormsf/oracles-presale)
[![Coverage Status](https://coveralls.io/repos/github/rstormsf/oracles-presale/badge.svg?branch=master)](https://coveralls.io/github/rstormsf/oracles-presale?branch=master)

[Full Test Report](https://rstormsf.github.io/oracles-presale/mochawesome.html)

```
·------------------------------------------------------------------------|-----------------------------------·
│                                  Gas                                   ·  Block limit: 17592186044415 gas  │
··········································|······························|····································
│  Methods                                ·          1 gwei/gas          ·          320.09 usd/eth           │
···················|······················|·········|··········|·········|················|···················
│  Contract        ·  Method              ·  Min    ·  Max     ·  Avg    ·  # calls       ·  usd (avg)       │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  blacklistInvestor   ·  19691  ·   23538  ·  21615  ·             2  ·            0.01  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  buy                 ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  claimTokens         ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  initialize          ·  23128  ·  125421  ·  46650  ·             9  ·            0.01  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  Presale             ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  transferOwnership   ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  whitelistInvestor   ·  23428  ·   64377  ·  57552  ·             6  ·            0.02  │
···················|······················|·········|··········|·········|················|···················
│  PresaleOracles  ·  whitelistInvestors  ·  23688  ·  119866  ·  87807  ·             3  ·            0.03  │
·------------------|----------------------|---------|----------|---------|----------------|------------------·

  22 passing (3m)
  ```

#Testnet deployment

Contract Deployment: https://kovan.etherscan.io/address/0x19001af36808e4c573a237bfc58ce282616f05b3#code

Called Initialize by Owner with params: "1510291574","1610291574","100000000000000000000","0x0039f22efb07a647557c7c5d17854cfd6d489ef3"
https://kovan.etherscan.io/tx/0xd83f75af7f8ebb02c6f79cd8a6e57ce619311b65f41ec618936558de3c116af9

Called whitelist with params: 0x0039f22efb07a647557c7c5d17854cfd6d489ef3
https://kovan.etherscan.io/tx/0x9781564e4365a35fc64694a777268de04bd21066126f6341f7eb3678fb820889

Called fallback with 0 ether: (expected error)
https://kovan.etherscan.io/tx/0x84abaa77a9f8b42799c00348a4d439db0af9b67ab45d252e7885b768e7ca9930

Called fallback with 0.03 ether:
https://kovan.etherscan.io/tx/0xdc32fa666a60fe8aa590d8fc7538b9e70852a2ae62750b7c0687d46e263d18ac
Verified forwarded funds as internal transaction:
https://kovan.etherscan.io/address/0x19001af36808e4c573a237bfc58ce282616f05b3#internaltx

Called blacklist by owner with params: 0x0039f22efb07a647557c7c5d17854cfd6d489ef3
https://kovan.etherscan.io/tx/0xe17dfeabd9bc2f7adc28ec3b83c4bf011e1864066c02ef689cbcbee4d9aeef51

Called fallback by non-whitelisted investor (expected an error) with 0.3 ether:
https://kovan.etherscan.io/tx/0x391c1e4d838876e38e4631279a3c9856cc08e5ecedd2a4d0fae6990e127af432

Called whitelistInvestors with params: [
    "0x62D9FB3358B4b83dB0280Eacc6a0fA5C6dDc7B4d","0xc15Ac3555FD6d6b569B9762D5289A3cc31325B1b"
]
https://kovan.etherscan.io/tx/0x048978a970e317e0117a5e342c875032a044ce65f8c1f35a3e18f7b4e29f25de