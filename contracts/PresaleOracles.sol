import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/token/BasicToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

pragma solidity ^0.4.17;

contract PresaleOracles is Ownable {
/*
 * PresaleOracles
 * Simple Presale contract
 * built by github.com/rstormsf Roman Storm
 */
    using SafeMath for uint256;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public cap;
    uint256 public rate;
    uint256 public totalInvestedInWei;
    uint256 public investorsLength;
    uint256 public minimumContribution;
    mapping(address => uint256) public investorBalances;
    address public vault;
    bool public isInitialized = false;
    // TESTED by Roman Storm
    function () public payable {
        buy();
    }
    //TESTED by Roman Storm
    function Presale() public {
    }
    //TESTED by Roman Storm
    function initialize(uint256 _startTime, uint256 _endTime, uint256 _cap, uint256 _minimumContribution, address _vault) public onlyOwner {
        require(!isInitialized);
        require(_startTime != 0);
        require(_endTime != 0);
        require(_endTime > _startTime);
        require(_cap != 0);
        require(_minimumContribution != 0);
        require(_vault != 0x0);
        require(_cap > _minimumContribution);
        startTime = _startTime;
        endTime = _endTime;
        cap = _cap;
        isInitialized = true;
        minimumContribution =_minimumContribution;
        vault = _vault;
    }
    //TESTED by Roman Storm
    function buy() public payable {
        require(isValidPurchase(msg.value));
        require(isInitialized);
        require(getTime() >= startTime && getTime() <= endTime);
        address investor = msg.sender;
        investorBalances[investor] += msg.value;
        totalInvestedInWei += msg.value;
        forwardFunds(msg.value);
    }
    
    //TESTED by Roman Storm
    function forwardFunds(uint256 _amount) internal {
        vault.transfer(_amount);
    }
    //TESTED by Roman Storm
    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
    
        BasicToken token = BasicToken(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
    }

    function getTime() internal view returns(uint256) {
        return now;
    }
    //TESTED by Roman Storm
    function isValidPurchase(uint256 _amount) public view returns(bool) {
        bool nonZero = _amount > 0;
        bool hasMinimumAmount = investorBalances[msg.sender].add(_amount) >= minimumContribution;
        bool withinCap = totalInvestedInWei.add(_amount) <= cap;
        return hasMinimumAmount && withinCap && nonZero;
    }
}