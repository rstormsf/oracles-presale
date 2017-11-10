// Build and Tested by Roman Storm rstormsf@gmail.com
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/token/BasicToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

pragma solidity ^0.4.17;

contract PresaleOracles is Ownable {
    uint256 public startTime;
    uint256 public endTime;
    uint256 public cap;
    uint256 public rate;
    bool public isInitialized = false;
    uint256 public totalInvestedInWei;
    mapping(address => uint256) public investorBalances;
    mapping(address => bool) public whitelist;
    uint256 public investorsLength;
    address public vault;
    // TESTED by Roman Storm
    function () public payable {
        buy();
    }
    //TESTED by Roman Storm
    function Presale() public {
    }
    //TESTED by Roman Storm
    function initialize(uint256 _startTime, uint256 _endTime, uint256 _cap, address _vault) public onlyOwner {
        require(!isInitialized);
        require(_startTime != 0);
        require(_endTime != 0);
        require(_endTime > _startTime);
        require(_cap != 0);
        require(_vault != 0x0);
        startTime = _startTime;
        endTime = _endTime;
        cap = _cap;
        isInitialized = true;
        vault = _vault;
    }
    //TESTED by Roman Storm
    function buy() public payable {
        require(whitelist[msg.sender]);
        require(msg.value > 0);
        require(isInitialized);
        require(getTime() >= startTime && getTime() <= endTime);
        require(totalInvestedInWei + msg.value <= cap);
        address investor = msg.sender;
        investorBalances[investor] += msg.value;
        totalInvestedInWei += msg.value;
        forwardFunds(msg.value);
    }
    
    //TESTED by Roman Storm
    function forwardFunds(uint256 _amount) internal {
        vault.transfer(_amount);
    }
    
    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
    
        BasicToken token = BasicToken(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
    }

    function whitelistInvestor(address _newInvestor) public onlyOwner {
        if(!whitelist[_newInvestor]) {
            whitelist[_newInvestor] = true;
            investorsLength++;
        }
    }
    function whitelistInvestors(address[] _investors) external onlyOwner {
        require(_investors.length <= 250);
        for(uint8 i=0; i<_investors.length;i++) {
            address newInvestor = _investors[i];
            if(!whitelist[newInvestor]) {
                whitelist[newInvestor] = true;
                investorsLength++;
            }
        }
    }
    function blacklistInvestor(address _investor) public onlyOwner {
        if(whitelist[_investor]) {
            delete whitelist[_investor];
            if(investorsLength != 0) {
                investorsLength--;
            }
        }
    }

    function getTime() internal view returns(uint256) {
        return now;
    }
}