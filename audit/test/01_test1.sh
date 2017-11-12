#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

CONTRACTSDIR=`grep ^CONTRACTSDIR= settings.txt | sed "s/^.*=//"`

SALESOL=`grep ^SALESOL= settings.txt | sed "s/^.*=//"`
SALEJS=`grep ^SALEJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

# Setting time to be a block representing one day
BLOCKSINDAY=1

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+75" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*3" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                 = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT      = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD             = '$PASSWORD'\n" | tee -a $TEST1OUTPUT

printf "CONTRACTSDIR         = '$CONTRACTSDIR'\n" | tee -a $TEST1OUTPUT

printf "SALESOL              = '$SALESOL'\n" | tee -a $TEST1OUTPUT
printf "SALEJS               = '$SALEJS'\n" | tee -a $TEST1OUTPUT

printf "DEPLOYMENTDATA       = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS            = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT          = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS         = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME          = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "STARTTIME            = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST1OUTPUT
printf "ENDTIME              = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp $CONTRACTSDIR/$SALESOL $SALESOL`

# --- Modify parameters ---
#`perl -pi -e "s/timePassed \> months\(3\)/timePassed \> 0/" $DTHSOL`
#`perl -pi -e "s/deadline \=  1499436000;.*$/deadline = $ENDTIME; \/\/ $ENDTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/\/\/\/ \@return total amount of tokens.*$/function overloadedTotalSupply() constant returns (uint256) \{ return totalSupply; \}/" $DAOCASINOICOTEMPSOL`
#`perl -pi -e "s/BLOCKS_IN_DAY \= 5256;*$/BLOCKS_IN_DAY \= $BLOCKSINDAY;/" $DAOCASINOICOTEMPSOL`

DIFFS1=`diff $CONTRACTSDIR/$SALESOL $SALESOL`
echo "--- Differences $CONTRACTSDIR/$SALESOL $SALESOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.4.18 --version | tee -a $TEST1OUTPUT

echo "var saleOutput=`solc_0.4.18 --optimize --combined-json abi,bin,interface $SALESOL`;" > $SALEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$SALEJS");
loadScript("functions.js");

var saleAbi = JSON.parse(saleOutput.contracts["$SALESOL:PresaleOracles"].abi);
var saleBin = "0x" + saleOutput.contracts["$SALESOL:PresaleOracles"].bin;

// console.log("DATA: saleAbi=" + JSON.stringify(saleAbi));
// console.log("DATA: saleBin=" + saleBin);

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

// -----------------------------------------------------------------------------
var saleMessage = "Deploy Presale Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + saleMessage);
var saleContract = web3.eth.contract(saleAbi);
var saleTx = null;
var saleAddress = null;
var sale = saleContract.new({from: contractOwnerAccount, data: saleBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        saleTx = contract.transactionHash;
      } else {
        saleAddress = contract.address;
        addAccount(saleAddress, "Presale");
        addPresaleContractAddressAndAbi(saleAddress, saleAbi);
        printTxData("saleAddress=" + saleAddress, saleTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(saleTx, saleMessage);
printPresaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var initialiseSaleMessage = "Initialise Contribution";
var startTime = $STARTTIME;
var endTime = $ENDTIME;
var cap = web3.toWei("10000", "ether");
var minimumContribution = web3.toWei("0.1", "ether");
// function initialize(uint256 _startTime, uint256 _endTime, uint256 _cap, uint256 _minimumContribution, address _vault) public onlyOwner
// -----------------------------------------------------------------------------
console.log("RESULT: " + initialiseSaleMessage);
var initialiseSaleTx = sale.initialize(startTime, endTime, cap, minimumContribution, multisig, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("initialiseSaleTx", initialiseSaleTx);
printBalances();
failIfTxStatusError(initialiseSaleTx, initialiseSaleMessage);
printPresaleContractDetails();
console.log("RESULT: ");


waitUntil("startTime", startTime, 0);


// -----------------------------------------------------------------------------
var whitelistMessage = "Whitelist";
// -----------------------------------------------------------------------------
console.log("RESULT: " + whitelistMessage);
var whitelist_1Tx = sale.whitelistInvestor(account3, {from: contractOwnerAccount, gas: 2000000});
var whitelist_2Tx = sale.whitelistInvestors([account4, account5, account7], {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("whitelist_1Tx", whitelist_1Tx);
printTxData("whitelist_2Tx", whitelist_2Tx);
printBalances();
failIfTxStatusError(whitelist_1Tx, whitelistMessage + " - whitelist(account3)");
failIfTxStatusError(whitelist_2Tx, whitelistMessage + " - whitelist([account4, account5, account7])");
printPresaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var blacklistMessage = "Blacklist";
// -----------------------------------------------------------------------------
console.log("RESULT: " + blacklistMessage);
var blacklist_1Tx = sale.blacklistInvestor(account4, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("blacklist_1Tx", blacklist_1Tx);
printBalances();
failIfTxStatusError(blacklist_1Tx, blacklistMessage + " - blacklist(account4)");
printPresaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: saleAddress, gas: 400000, value: web3.toWei("1000", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account4, to: saleAddress, gas: 400000, value: web3.toWei("1000", "ether")});
var sendContribution1_3Tx = eth.sendTransaction({from: account5, to: saleAddress, gas: 400000, value: web3.toWei("1000", "ether")});
var sendContribution1_4Tx = eth.sendTransaction({from: account6, to: saleAddress, gas: 400000, value: web3.toWei("1000", "ether")});
while (txpool.status.pending > 0) {
}
var sendContribution1_5Tx = eth.sendTransaction({from: account7, to: saleAddress, gas: 400000, value: web3.toWei("8000.00000000001", "ether")});
while (txpool.status.pending > 0) {
}
var sendContribution1_6Tx = eth.sendTransaction({from: account7, to: saleAddress, gas: 400000, value: web3.toWei("7999", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printTxData("sendContribution1_3Tx", sendContribution1_3Tx);
printTxData("sendContribution1_4Tx", sendContribution1_4Tx);
printTxData("sendContribution1_5Tx", sendContribution1_5Tx);
printTxData("sendContribution1_6Tx", sendContribution1_6Tx);
printBalances();
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " ac3 1000 ETH");
passIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " ac4 1000 ETH - Expecting failure, not whitelisted");
failIfTxStatusError(sendContribution1_3Tx, sendContribution1Message + " ac5 1000 ETH");
passIfTxStatusError(sendContribution1_4Tx, sendContribution1Message + " ac6 1000 ETH - Expecting failure, not whitelisted");
passIfTxStatusError(sendContribution1_5Tx, sendContribution1Message + " ac7 8000.00000000001 ETH - Expecting failure, amount will blow the cap");
failIfTxStatusError(sendContribution1_6Tx, sendContribution1Message + " ac7 7999 ETH");
printPresaleContractDetails();
console.log("RESULT: ");


waitUntil("endTime", endTime, 0);


// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution After End";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2_1Tx = eth.sendTransaction({from: account3, to: saleAddress, gas: 400000, value: web3.toWei("1", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printBalances();
passIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " ac3 1 ETH - Expecting failure, after end");
printPresaleContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
