require('dotenv').config();
const ARRAY_OF_ADDRESSES = require('./ARRAY_OF_ADDRESSES.json');
const RPC_PORT = process.env.RPC_PORT;
const PRESALE_ADDRESS = process.env.PRESALE_ADDRESS;
const UNLOCKED_ADDRESS = process.env.UNLOCKED_ADDRESS;

const ICO_ABI = require('../build/contracts/PresaleOracles.json').abi;
const Web3 = require('web3');
const provider = new Web3.providers.HttpProvider(`http://localhost:${RPC_PORT}`);
const web3 = new Web3(provider);

const { filterAddresses, setup } = require('./filterAddresses');
setup({ web3Param: web3, contribAddress: PRESALE_ADDRESS});
filterAddresses(ARRAY_OF_ADDRESSES).then(async (toWhitelist) => {
    console.log(toWhitelist.length);
    const addPerTx = 160;
    const slices = Math.ceil(toWhitelist.length / addPerTx);
    console.log(`THIS SCRIPT WILL GENERATE ${slices} transactions`);
    var txcount = await web3.eth.getTransactionCount(UNLOCKED_ADDRESS);
    const nonce = web3.utils.toHex(txcount);
    console.log('STARTED', nonce);
    return sendTransactionToContribution({array: toWhitelist, slice: slices, addPerTx, nonce});
}).then(console.log).catch(console.error);

const GAS_PRICE = web3.utils.toWei(process.env.GAS_PRICE, 'gwei');
const GAS_LIMIT = '6700000';
const myContract = new web3.eth.Contract(ICO_ABI, PRESALE_ADDRESS, {
    from: UNLOCKED_ADDRESS, // default from address
    gasPrice: GAS_PRICE,
    gas: GAS_LIMIT // default gas price in wei
});


async function sendTransactionToContribution({array, slice, addPerTx, nonce}) {
    if(array.length === 0){
        console.log('array doesnot have not whitelisted addresses');
        process.exit();
    }
    const start = (slice - 1) * addPerTx;
    const end = slice * addPerTx;
    const arrayToProcess = array.slice(start, end);
    let encodedData = myContract.methods.whitelistInvestors(arrayToProcess).encodeABI();
    
    console.log('Processing array length', arrayToProcess.length, arrayToProcess[0], arrayToProcess[arrayToProcess.length - 1]);
    return new Promise((res) => {
        web3.eth.estimateGas({
            from: UNLOCKED_ADDRESS, to: PRESALE_ADDRESS, data: encodedData, gas: GAS_LIMIT, gasPrice: GAS_PRICE
        }).then((gasNeeded) => {
            console.log('gasNeeded', gasNeeded);
            web3.eth.sendTransaction({
                from: UNLOCKED_ADDRESS, to: PRESALE_ADDRESS, data: encodedData, gas: gasNeeded, gasPrice: GAS_PRICE, nonce
            }).on('transactionHash', function(hash){console.log('hash', hash)});
            slice--;
            if (slice > 0) {
                nonce = parseInt(nonce, 16);
                nonce++;
                nonce = web3.utils.toHex(nonce);
                sendTransactionToContribution({array, slice, addPerTx, nonce});
            } else {
                res({ result: 'completed' });
                // process.exit();
            }

        });
    })
}