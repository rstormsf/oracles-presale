const PresaleOracles = artifacts.require("PresaleOraclesMock.sol");
const BigNumber = web3.BigNumber;
require('chai')
.use(require('chai-as-promised'))
.use(require('chai-bignumber')(web3.BigNumber))
.should();

const moment = require('moment');

const ETHER = new web3.BigNumber(10).toPower(18);

function getTime() {
  return Math.floor(Date.now() / 1000);
}

function latestTime() {
  return web3.eth.getBlock('latest').timestamp;
}

let PRESALE_START_DATE, PRESALE_END_DATE;
contract('Presale', function(accounts) {
    let presaleContract;

    beforeEach(async () => {
        presaleContract = await PresaleOracles.new();
    });

    it('constructor should set owner', async () => {
        accounts[0].should.be.equal(
            await presaleContract.owner()
        );
    });
    it('can not buy if not initialized', async () => {
        await presaleContract.sendTransaction({amount: ETHER})
        .should.be.rejectedWith('invalid opcode');
    })

    describe('#initilize', async () => {
        
        beforeEach(() => {
            PRESALE_START_DATE = moment('2017-12-11T16:00:00Z').unix();
            PRESALE_END_DATE = moment('2017-12-18T16:00:00Z').unix();
        })
        it('rejects if not sent by owner', async () => {
            await presaleContract.initialize(PRESALE_START_DATE, PRESALE_END_DATE, ETHER, accounts[1], {from: accounts[1]})
                .should.be.rejectedWith('invalid opcode');
        })
        it('sets values', async () => {
            await presaleContract.initialize(PRESALE_START_DATE, PRESALE_END_DATE, ETHER, accounts[1], {from: accounts[0]})
            true.should.be.equal(
                await presaleContract.isInitialized()
            )
            PRESALE_START_DATE.should.be.bignumber.equal(
                await presaleContract.startTime()
            )
            PRESALE_END_DATE.should.be.bignumber.equal(
                await presaleContract.endTime()
            )
            ETHER.should.be.bignumber.equal(
                await presaleContract.cap()
            )
            accounts[1].should.be.equal(
                await presaleContract.vault()
            )
        })
        it('cannot initialize twice', async () => {
            // require(!isInitialized);
            await presaleContract.initialize(PRESALE_START_DATE, PRESALE_END_DATE, ETHER, accounts[1], {from: accounts[0]})
            await presaleContract.initialize(PRESALE_START_DATE, PRESALE_END_DATE, ETHER, accounts[1], {from: accounts[0]})
                .should.be.rejectedWith('invalid opcode');
        })
        it('startTime cannot be 0', async () => {
            // require(_startTime != 0);
            await presaleContract.initialize(0, PRESALE_END_DATE, ETHER, accounts[1], {from: accounts[1]})
            .should.be.rejectedWith('invalid opcode');
        })
        it('endTime cannot be 0', async () => {
            // require(_endTime != 0);
            await presaleContract.initialize(PRESALE_START_DATE, 0, ETHER, accounts[1], {from: accounts[1]})
            .should.be.rejectedWith('invalid opcode');
        })
        it('endTime cannot be less than startTime', async () => {
            // require(_endTime > _startTime);
            await presaleContract.initialize(PRESALE_END_DATE, PRESALE_START_DATE, ETHER, accounts[1], {from: accounts[1]})
            .should.be.rejectedWith('invalid opcode');
        })
        it('cap cannot be 0', async () => {
            // require(_cap != 0);
            await presaleContract.initialize(PRESALE_START_DATE, PRESALE_END_DATE, 0, accounts[1], {from: accounts[1]})
            .should.be.rejectedWith('invalid opcode');
        })
        it('vault cannot be 0x0', async () => {
            // require(_vault != 0x0);
            await presaleContract.initialize(PRESALE_START_DATE, PRESALE_END_DATE, ETHER, '0x0', {from: accounts[1]})
            .should.be.rejectedWith('invalid opcode');
        })
    })

    describe('#buy', async () => {

        beforeEach(async () => {
            PRESALE_START_DATE = moment('2017-12-11T16:00:00Z').unix();
            PRESALE_END_DATE = moment('2017-12-18T16:00:00Z').unix();
            await presaleContract.initialize(PRESALE_START_DATE, PRESALE_END_DATE, ETHER.mul(2), accounts[1], {from: accounts[0]})
        })
        it('cannot buy if not whitelisted', async () => {
            // require(whitelist[msg.sender]);
            await presaleContract.sendTransaction({amount: ETHER})
            .should.be.rejectedWith('invalid opcode');
        })
        it('cannot buy if not value is 0', async () => {
            // require(msg.value > 0);
            await presaleContract.setTime(PRESALE_START_DATE);
            await presaleContract.whitelistInvestor(accounts[0]);
            await presaleContract.sendTransaction({value: 0})
            .should.be.rejectedWith('invalid opcode');
        })

        it('can not buy if not initialized', async () => {
            // require(isInitialized);
            await presaleContract.sendTransaction({amount: ETHER})
            .should.be.rejectedWith('invalid opcode');
        })

        it('can not buy if time is not within startTime&endTime', async ()=> {
            // require(now >= startTime && now <= endTime);
            await presaleContract.setTime(PRESALE_START_DATE - 1);
            await presaleContract.whitelistInvestor(accounts[0]);
            await presaleContract.sendTransaction({value: ETHER})
            .should.be.rejectedWith('invalid opcode');
            await presaleContract.setTime(PRESALE_END_DATE + 1);
            await presaleContract.sendTransaction({value: ETHER})
            .should.be.rejectedWith('invalid opcode');
        })

        it('can not buy more than cap', async () => {
            // require(totalInvestedInWei + msg.value <= cap);
            await presaleContract.setTime(PRESALE_START_DATE);
            await presaleContract.whitelistInvestor(accounts[0]);
            await presaleContract.sendTransaction({value: ETHER.mul(2) + 1})
            .should.be.rejectedWith('invalid opcode');
        })

        it('happy path', async () => {
            // investorBalances[investor] += msg.value;
            // totalInvestedInWei += msg.value;
            // forwardFunds(msg.value);
            const vault = accounts[1];
            const preVaultBalance = await web3.eth.getBalance(vault);
            await presaleContract.setTime(PRESALE_START_DATE);
            await presaleContract.whitelistInvestor(accounts[0]);
            await presaleContract.sendTransaction({value: ETHER});
            ETHER.should.be.bignumber.equal(
                await presaleContract.investorBalances(accounts[0])
            )
            ETHER.should.be.bignumber.equal(
                await presaleContract.totalInvestedInWei()
            )
            preVaultBalance.add(ETHER).should.be.bignumber.equal(
                await web3.eth.getBalance(vault)
            )
            await presaleContract.sendTransaction({value: ETHER});

            ETHER.mul(2).should.be.bignumber.equal(
                await presaleContract.investorBalances(accounts[0])
            )
            ETHER.mul(2).should.be.bignumber.equal(
                await presaleContract.totalInvestedInWei()
            )
            preVaultBalance.add(ETHER.mul(2)).should.be.bignumber.equal(
                await web3.eth.getBalance(vault)
            )
        })
    })

    describe('#whitelistInvestor', async ()=>{
        it('cannot by called by non-owner', async ()=> {
            await presaleContract.whitelistInvestor(accounts[0], {from: accounts[1]})
                .should.be.rejectedWith('invalid opcode');
        })
        it('whitelists an investor', async ()=> {
            '0'.should.be.bignumber.equal(
                await presaleContract.investorsLength()
            )
            false.should.be.equal(
                await presaleContract.whitelist(accounts[0])
            )
            await presaleContract.whitelistInvestor(accounts[0]);
            true.should.be.equal(
                await presaleContract.whitelist(accounts[0])
            )
            '1'.should.be.bignumber.equal(
                await presaleContract.investorsLength()
            )
        })
    })
    describe('#whitelistInvestors', async ()=>{
        it('cannot by called by non-owner', async ()=> {
            await presaleContract.whitelistInvestors([accounts[0]], {from: accounts[1]})
                .should.be.rejectedWith('invalid opcode');
        })
        it('whitelists investors', async ()=> {
            '0'.should.be.bignumber.equal(
                await presaleContract.investorsLength()
            )
            false.should.be.equal(
                await presaleContract.whitelist(accounts[0])
            )
            await presaleContract.whitelistInvestors([accounts[0], accounts[1], accounts[2]]);
            true.should.be.equal(
                await presaleContract.whitelist(accounts[2])
            )
            '3'.should.be.bignumber.equal(
                await presaleContract.investorsLength()
            )
        })
    })
    describe('#blacklistInvestor', async ()=>{
        it('cannot by called by non-owner', async ()=> {
            await presaleContract.blacklistInvestor(accounts[0], {from: accounts[1]})
                .should.be.rejectedWith('invalid opcode');
        })
        it('blacklist an investors', async ()=> {
            '0'.should.be.bignumber.equal(
                await presaleContract.investorsLength()
            )
            false.should.be.equal(
                await presaleContract.whitelist(accounts[0])
            )
            await presaleContract.whitelistInvestors([accounts[0], accounts[1], accounts[2]]);
            true.should.be.equal(
                await presaleContract.whitelist(accounts[0])
            )
            '3'.should.be.bignumber.equal(
                await presaleContract.investorsLength()
            )
            await presaleContract.blacklistInvestor(accounts[0]);
            false.should.be.equal(
                await presaleContract.whitelist(accounts[0])
            )
            '2'.should.be.bignumber.equal(
                await presaleContract.investorsLength()
            )
        })
    })
});