require('dotenv').config();
let ARRAY_OF_ADDRESSES = require('./ARRAY_OF_ADDRESSES.json');
ARRAY_OF_ADDRESSES = Array.from(new Set(ARRAY_OF_ADDRESSES));

const Web3 = require('web3');
const MAINET_RPC_URL = 'https://mainnet.infura.io/metamask';
const provider = new Web3.providers.HttpProvider(MAINET_RPC_URL);
const web3 = new Web3(provider);

const ContributionABI = require('../build/contracts/PresaleOracles.json').abi;
var myContract = new web3.eth.Contract(ContributionABI, process.env.PRESALE_ADDRESS);

ARRAY_OF_ADDRESSES.forEach((address) => {
    var res =  web3.utils.isAddress(address);
    if(!res){
        console.log('invalid:', address);
        
    }
})
isWhitelisted(ARRAY_OF_ADDRESSES);


function isWhitelisted(toCheckAddress) {
    var count = 0;
    var leftRun = toCheckAddress.length;
    let notWhitelisted = [];
    let already = [];
    let promise = new Promise((res) => {
        if(toCheckAddress.length === 0 || !toCheckAddress) {
            rej('array is empty');
        }
        toCheckAddress.forEach((address, index) => {
            myContract.methods.whitelist(address).call().then((isWhitelisted) => {
                leftRun--;
                if (!isWhitelisted) {
                    count++;
                    notWhitelisted.push(address);
                } else { 
                    already.push(address);
                    // console.log('already whitelisted', address);
                }
                if (leftRun === 0) {
                    console.log('FINISHED filtering array! notWhitelisted: ', notWhitelisted.length, already.length, ARRAY_OF_ADDRESSES.length);
                    res(notWhitelisted);
                }
            });
        })
    })
    return promise;
}