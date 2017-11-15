# PresaleOracles_flat

Source file [../../flat/PresaleOracles_flat.sol](../../flat/PresaleOracles_flat.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Ok
library SafeMath {
  // BK Ok
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    // BK Ok
    uint256 c = a * b;
    // BK Ok
    assert(a == 0 || c / a == b);
    // BK Ok
    return c;
  }

  // BK Ok
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // BK Ok
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    // BK Ok
    return c;
  }

  // BK Ok
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    // BK Ok
    assert(b <= a);
    // BK Ok
    return a - b;
  }

  // BK Ok
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    // BK Ok
    uint256 c = a + b;
    // BK Ok
    assert(c >= a);
    // BK Ok
    return c;
  }
}

// BK Ok
contract Ownable {
  // BK Ok
  address public owner;


  // BK Ok - Event
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  // BK Ok - Constructor
  function Ownable() {
    // BK Ok
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  // BK Ok
  modifier onlyOwner() {
    // BK Ok
    require(msg.sender == owner);
    // BK Ok
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  // BK Ok - Only owner can execute
  function transferOwnership(address newOwner) onlyOwner public {
    // BK Ok
    require(newOwner != address(0));
    // BK Ok - Log event
    OwnershipTransferred(owner, newOwner);
    // BK Ok
    owner = newOwner;
  }

}

// BK Ok
contract ERC20Basic {
  // BK Ok
  uint256 public totalSupply;
  // BK Ok
  function balanceOf(address who) public constant returns (uint256);
  // BK Ok
  function transfer(address to, uint256 value) public returns (bool);
  // BK Ok - Event
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// BK Ok
contract BasicToken is ERC20Basic {
  // BK Ok
  using SafeMath for uint256;

  // BK Ok
  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  // BK Ok
  function transfer(address _to, uint256 _value) public returns (bool) {
    // BK Ok
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    // BK Ok
    balances[msg.sender] = balances[msg.sender].sub(_value);
    // BK Ok
    balances[_to] = balances[_to].add(_value);
    // BK Ok - Log event
    Transfer(msg.sender, _to, _value);
    // BK Ok
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  // BK Ok - Constant function
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    // BK Ok
    return balances[_owner];
  }

}

// BK Ok
contract PresaleOracles is Ownable {
/*
 * PresaleOracles
 * Simple Presale contract
 * built by github.com/rstormsf Roman Storm
 */
    // BK Ok
    using SafeMath for uint256;
    // BK Next 6 Ok
    uint256 public startTime;
    uint256 public endTime;
    uint256 public cap;
    uint256 public rate;
    uint256 public totalInvestedInWei;
    uint256 public minimumContribution;
    // BK Next 2 Ok
    mapping(address => uint256) public investorBalances;
    mapping(address => bool) public whitelist;
    // BK Ok
    uint256 public investorsLength;
    // BK Ok
    address public vault;
    // BK Ok
    bool public isInitialized = false;
    // TESTED by Roman Storm
    // BK Ok
    function () public payable {
        // BK Ok
        buy();
    }
    //TESTED by Roman Storm
    // BK Ok - Constructor
    function Presale() public {
    }
    //TESTED by Roman Storm
    // BK Ok - Only owner can execute
    function initialize(uint256 _startTime, uint256 _endTime, uint256 _cap, uint256 _minimumContribution, address _vault) public onlyOwner {
        // BK Ok
        require(!isInitialized);
        // BK Next 7 Ok
        require(_startTime != 0);
        require(_endTime != 0);
        require(_endTime > _startTime);
        require(_cap != 0);
        require(_minimumContribution != 0);
        require(_vault != 0x0);
        require(_cap > _minimumContribution);
        // BK Next 6 Ok
        startTime = _startTime;
        endTime = _endTime;
        cap = _cap;
        isInitialized = true;
        minimumContribution = _minimumContribution;
        vault = _vault;
    }
    //TESTED by Roman Storm
    // BK Ok - Payable
    function buy() public payable {
        // BK Ok
        require(whitelist[msg.sender]);
        // BK Ok
        require(isValidPurchase(msg.value));
        // BK Ok
        require(isInitialized);
        // BK Ok
        require(getTime() >= startTime && getTime() <= endTime);
        // BK Ok
        address investor = msg.sender;
        // BK Ok
        investorBalances[investor] += msg.value;
        // BK Ok
        totalInvestedInWei += msg.value;
        // BK Ok
        forwardFunds(msg.value);
    }
    
    //TESTED by Roman Storm
    // BK Ok
    function forwardFunds(uint256 _amount) internal {
        // BK Ok
        vault.transfer(_amount);
    }
    //TESTED by Roman Storm
    // BK Ok - Only owner can execute
    function claimTokens(address _token) public onlyOwner {
        // BK Ok
        if (_token == 0x0) {
            // BK Ok
            owner.transfer(this.balance);
            // BK Ok
            return;
        }
    
        // BK Ok
        BasicToken token = BasicToken(_token);
        // BK Ok
        uint256 balance = token.balanceOf(this);
        // BK Ok
        token.transfer(owner, balance);
    }

    // BK Ok
    function getTime() internal view returns(uint256) {
        // BK Ok
        return now;
    }
    //TESTED by Roman Storm
    // BK Ok - Constant function
    function isValidPurchase(uint256 _amount) public view returns(bool) {
        // BK Ok
        bool nonZero = _amount > 0;
        // BK Ok
        bool hasMinimumAmount = investorBalances[msg.sender].add(_amount) >= minimumContribution;
        // BK Ok
        bool withinCap = totalInvestedInWei.add(_amount) <= cap;
        // BK Ok
        return hasMinimumAmount && withinCap && nonZero;
    }
    //TESTED by Roman Storm
    // BK Ok - Only owner can execute
    function whitelistInvestor(address _newInvestor) public onlyOwner {
        // BK Ok
        if(!whitelist[_newInvestor]) {
            // BK Ok
            whitelist[_newInvestor] = true;
            // BK Ok
            investorsLength++;
        }
    }
    //TESTED by Roman Storm
    // BK Ok - Only owner can execute
    function whitelistInvestors(address[] _investors) external onlyOwner {
        // BK Ok
        require(_investors.length <= 250);
        // BK Ok
        for(uint8 i=0; i<_investors.length;i++) {
            // BK Ok
            address newInvestor = _investors[i];
            // BK Ok
            if(!whitelist[newInvestor]) {
                // BK Ok
                whitelist[newInvestor] = true;
                // BK Ok
                investorsLength++;
            }
        }
    }
    // BK Ok - Only owner can execute
    function blacklistInvestor(address _investor) public onlyOwner {
        // BK Ok
        if(whitelist[_investor]) {
            // BK Ok
            delete whitelist[_investor];
            // BK Ok
            if(investorsLength != 0) {
                // BK Ok
                investorsLength--;
            }
        }
    }
}


```
