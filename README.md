# Oracles Presale Contract
[![Build Status](https://travis-ci.org/rstormsf/oracles-presale.svg?branch=master)](https://travis-ci.org/rstormsf/oracles-presale)
[![Coverage Status](https://coveralls.io/repos/github/rstormsf/oracles-presale/badge.svg?branch=master)](https://coveralls.io/github/rstormsf/oracles-presale?branch=master)

[Full Test Report](https://rstormsf.github.io/oracles-presale/mochawesome.html)
Presale contract that records investor's balances and sends ether to presale owner.
It allows to set minimum Contrubution amount, start Date, end Date.

To use:
1. Flat [contracts/PresaleOracles.sol](contracts/PresaleOracles.sol) by using [oracles-combine-solidity](github.com/oraclesorg/oracles-combine-solidity/commits/master)
2. Deploy [flat file](flat/PresaleOracles_flat.sol)
3. Call `initialize` with following params:

    -startTime in unix format 

    -endTime in unix format 

    -cap in wei format 

    -minimumContribution in wei format

    -vault (eth address where funds will be collected) 
    
Example: 

    "1510291574","1610291574","100000000000000000000","0x0039f22efb07a647557c7c5d17854cfd6d489ef3"

    startTime: `Friday, November 10, 2017 5:26:14 AM `
    endTime: `Sunday, January 10, 2021 3:12:54 PM `
    cap: `100 eth `
    vault: `0x0039f22efb07a647557c7c5d17854cfd6d489ef3`
4. Whitelist investors by calling `whitelistInvestors` with array of addresses. Example:
["0x62D9FB3358B4b83dB0280Eacc6a0fA5C6dDc7B4d","0xc15Ac3555FD6d6b569B9762D5289A3cc31325B1b"]
5. Let whitelisted investors send money to contract's address


Contract: Presale
    <span style="color:green">✓</span> constructor should set owner
    <span style="color:green">✓</span> can not buy if not initialized <span style="color:green">(22623 gas)</span>
    #initilize
      <span style="color:green">✓</span> rejects if not sent by owner <span style="color:green">(25358 gas)</span>
      <span style="color:green">✓</span> sets values <span style="color:green">(131519 gas)</span>
      <span style="color:green">✓</span> cannot initialize twice <span style="color:green">(157189 gas)</span>
      <span style="color:green">✓</span> startTime cannot be 0 <span style="color:green">(25102 gas)</span>
      <span style="color:green">✓</span> endTime cannot be 0 <span style="color:green">(25166 gas)</span>
      <span style="color:green">✓</span> endTime cannot be less than startTime <span style="color:green">(25358 gas)</span>
      <span style="color:green">✓</span> cap cannot be 0 <span style="color:green">(24910 gas)</span>
      <span style="color:green">✓</span> vault cannot be 0x0 <span style="color:green">(24078 gas)</span>
      <span style="color:green">✓</span> minimumContribution cannot be 0 <span style="color:green">(24910 gas)</span>
    #buy
      <span style="color:green">✓</span> cannot buy if not value is 0 <span style="color:green">(64231 gas)</span>
      <span style="color:green">✓</span> cannot buy if not value is less than minimum <span style="color:green">(64231 gas)</span>
      <span style="color:green">✓</span> can not buy if time is not within startTime&endTime <span style="color:green">(116233 gas)</span>
      <span style="color:green">✓</span> can not buy more than cap <span style="color:green">(64236 gas)</span>
      <span style="color:green">✓</span> happy path <span style="color:green">(178974 gas)</span>

·-----------------------------------------------------------------------|-----------------------------------·
│                                  Gas                                  ·  Block limit: 17592186044415 gas  │
·········································|······························|····································
│  Methods                               ·          1 gwei/gas          ·          297.51 usd/eth           │
···················|·····················|·········|··········|·········|················|···················
│  Contract        ·  Method             ·  Min    ·  Max     ·  Avg    ·  # calls       ·  usd (avg)       │
···················|·····················|·········|··········|·········|················|···················
│  PresaleOracles  ·  buy                ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|·····················|·········|··········|·········|················|···················
│  PresaleOracles  ·  claimTokens        ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|·····················|·········|··········|·········|················|···················
│  PresaleOracles  ·  initialize         ·  24078  ·  131519  ·  46359  ·            10  ·            0.01  │
···················|·····················|·········|··········|·········|················|···················
│  PresaleOracles  ·  Presale            ·      -  ·       -  ·      -  ·             0  ·               -  │
···················|·····················|·········|··········|·········|················|···················
│  PresaleOracles  ·  transferOwnership  ·      -  ·       -  ·      -  ·             0  ·               -  │
·------------------|---------------------|---------|----------|---------|----------------|------------------·

  <span style="color:green">16 passing (2m)</span>

# Testnet deployment

Contract Deployment: https://kovan.etherscan.io/address/0x5a79f8aaae55924117d55d72338c4a4b9d1b5315#readContract

Called Initialize by Owner with params: 
"1510291574","1610291574","40000000000000000000000","1000000000000000000","0x0039f22efb07a647557c7c5d17854cfd6d489ef3"
(40000 eth cap, 1 eth minimum)
https://kovan.etherscan.io/tx/0x2ac165c7efafc093019c113534f6745bc2a5df911ba53d121c33c55d681b3fb6

Called fallback with 0.5 ether: (expected error)
https://kovan.etherscan.io/tx/0x84abaa77a9f8b42799c00348a4d439db0af9b67ab45d252e7885b768e7ca9930

Called buy with 1 ether:
https://kovan.etherscan.io/tx/0xdc32fa666a60fe8aa590d8fc7538b9e70852a2ae62750b7c0687d46e263d18ac
Verified forwarded funds as internal transaction.

