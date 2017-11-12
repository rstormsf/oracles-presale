require('dotenv').config();
const ContributionABI = require('../build/contracts/PresaleOracles.json').abi;

// const Web3 = require('web3');
// // const MAINET_RPC_URL = 'https://mainnet.infura.io/metamask'
// // const KOVAN_RPC_URL = 'https://kovan.infura.io/metamask'
// const local = `http://localhost:${process.env.RPC_PORT}`;
// const provider = new Web3.providers.HttpProvider(local);
// const web3 = new Web3(provider);
// var myContract = new web3.eth.Contract(ContributionABI, '0x6F3f79941f89E03D4aF9bDb8BE0623DC24F2bef0');
// const ARRAY_OF_ADDRESSES = require('./ARRAY_OF_ADDRESSES.json');
// filterAddresses(ARRAY_OF_ADDRESSES).then(console.log)
function setup({web3Param, contribAddress}){
    web3 = web3Param;
    CONTRIBUTION_ADDRESS = contribAddress
    myContract = new web3.eth.Contract(ContributionABI, CONTRIBUTION_ADDRESS);
}

function readCap() {
    myContract.methods.cap().call().then((cap) => {
        console.log('cap', cap);
    })
}
function isWhitelisted(toCheckAddress) {
    readCap();
    var count = 0;
    var leftRun = toCheckAddress.length;
    let notWhitelisted = [];
    let promise = new Promise((res) => {
        if(toCheckAddress.length === 0 || !toCheckAddress) {
            rej('array is empty');
        }
        console.log(toCheckAddress.length)
        toCheckAddress.forEach((address, index) => {
            myContract.methods.whitelist(address).call().then((isWhitelisted) => {
                leftRun--;
                if (!isWhitelisted) {
                    count++;
                    notWhitelisted.push(address);
                }
                if (leftRun === 0) {
                    console.log('FINISHED! notWhitelisted: ', notWhitelisted.length);
                    res(notWhitelisted);
                }
            });
        })
    })
    return promise;
}

function filterAddresses(arrayOfAddresses) {
    const date = Date.now();
    console.log(date, 'DATE NOW', arrayOfAddresses.length);
    return new Promise((res, rej) => {
       return isWhitelisted(arrayOfAddresses).then((whitelistedAddress) => {
            res(whitelistedAddress);
        }).catch(console.error);
    })
}
exports.filterAddresses = filterAddresses;
exports.isWhitelisted = isWhitelisted;
exports.setup = setup;