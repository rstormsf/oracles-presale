var PresaleOracles = artifacts.require("./PresaleOracles.sol");

module.exports = function(deployer, network) {
    if(network !== 'development'){
        deployer.deploy(PresaleOracles).then(async ()=> {
            let presale = await PresaleOracles.deployed();
            console.log(presale.address);
        })
    }
};
