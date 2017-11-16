# Oracles Network Presale Contract Audit

## Summary

[Oracles Network](https://oracles.org/) intends to run a presale commencing in Nov 2017.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Oracles Network's presale Ethereum smart contract.

This audit has been conducted on Oracles Network's source code in commits
[5bc4391](https://github.com/oraclesorg/oracles-presale/commit/5bc439115ecebb0a52cfe9305f00f89756c5a90a) and
[565e090](https://github.com/oraclesorg/oracles-presale/commit/565e090b0a2a37f36aedf3c5585cb03f2cfb4b33).

No potential vulnerabilities have been identified in the presale contract.

<br />

### Mainnet Addresses

* PresaleOracles - [0xc8fe4a2d14Cb9027Ef955D15E8BF811a6DB0Bf74](https://etherscan.io/address/0xc8fe4a2d14Cb9027Ef955D15E8BF811a6DB0Bf74#code)
  with a copy of the deployed code saved in [deployed-contracts/PresaleOracles_deployed_at_0xc8fe4a2d14Cb9027Ef955D15E8BF811a6DB0Bf74.sol](deployed-contracts/PresaleOracles_deployed_at_0xc8fe4a2d14Cb9027Ef955D15E8BF811a6DB0Bf74.sol)
* Wallet - [0x04c62019ab478bFf5874E7B7D9bC84FCF7e30025](https://etherscan.io/address/0x04c62019ab478bFf5874E7B7D9bC84FCF7e30025#code)

<br />

### Presale Contract

Ethers contributed by participants to the presale contract are immediately transferred to the presale wallet, reducing any risk of the loss
of ethers in this bespoke smart contract.

No tokens are generated for these contributions.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

* **LOW IMPORTANCE** Use the OpenZeppelin *Claimable* contract instead of the *Ownable* contract to provide more safety during the
  ownership transfer process
  * [x] Updated in [565e090](https://github.com/oraclesorg/oracles-presale/commit/565e090b0a2a37f36aedf3c5585cb03f2cfb4b33)
* **LOW IMPORTANCE** The variable `PresaleOracles.rate` is unused and can be removed
  * [x] Updated in [565e090](https://github.com/oraclesorg/oracles-presale/commit/565e090b0a2a37f36aedf3c5585cb03f2cfb4b33)
* **LOW IMPORTANCE** Consider adding the logging of an event for each contribution, like `Contribution(address investor, uint investorAmount, uint investorTotal, uint totalAmount)`.
  This data can then be easily extracted using a script, if there are many individual contributions
  * [x] Updated in [565e090](https://github.com/oraclesorg/oracles-presale/commit/565e090b0a2a37f36aedf3c5585cb03f2cfb4b33)
* **LOW IMPORTANCE** `BasicToken` can be replaced with the `ERC20Basic` interface in `PresaleOracles.claimTokens(...)`, and the `BasicToken`
  contract source code can be removed
  * [x] Updated in [565e090](https://github.com/oraclesorg/oracles-presale/commit/565e090b0a2a37f36aedf3c5585cb03f2cfb4b33)

<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the presale contract.

<br />

<hr />

## Scope

This audit is into the technical aspects of the presale contract. The primary aim of this audit is to ensure that funds
contributed to this contract is not easily attacked or stolen by third parties. The secondary aim of this audit is that
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the Oracles Network's business proposition, the individuals
involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition
before funding any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on
the crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as
duplicating crowdsale websites. Potential participants should NOT just click on any links received through these messages.
Scammers have also hacked the crowdsale website to replace the crowdsale contract address with their scam address.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address
matches the audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

* This presale contract has a low risk of having the ETH hacked or stolen, as any contributions by participants are immediately transferred
  to the presale wallet.

<br />

<hr />

## Testing

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy Presale contract
* [x] Initialise contract
* [x] Whitelist accounts
* [x] Blacklist accounts
* [x] Send contributions for whitelisted addresses and blacklisted address (expecting failure)

<br />

<hr />

## Code Review

* [x] [code-review/PresaleOracles_flat.md](code-review/PresaleOracles_flat.md)
  * [x] contract Ownable 
  * [x] contract ERC20Basic 
  * [x] contract BasicToken is ERC20Basic 
  * [x] contract PresaleOracles is Ownable 

<br />

The following warning messages are generated when using the Solidity compiler 0.4.18 and are of low importance, due to recent changes to the
Solidity compiler version:

```
$ solc_0.4.18 PresaleOracles_flat.sol 
PresaleOracles_flat.sol:40:3: Warning: No visibility specified. Defaulting to "public".
  function Ownable() {
  ^
Spanning multiple lines.
PresaleOracles_flat.sol:4:3: Warning: Function state mutability can be restricted to pure
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
  ^
Spanning multiple lines.
PresaleOracles_flat.sol:10:3: Warning: Function state mutability can be restricted to pure
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
  ^
Spanning multiple lines.
PresaleOracles_flat.sol:17:3: Warning: Function state mutability can be restricted to pure
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
  ^
Spanning multiple lines.
PresaleOracles_flat.sol:22:3: Warning: Function state mutability can be restricted to pure
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
  ^
Spanning multiple lines.
PresaleOracles_flat.sol:127:5: Warning: Function state mutability can be restricted to pure
    function Presale() public {
    ^
Spanning multiple lines.
```

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Oracles Network - Nov 15 2017. The MIT Licence.