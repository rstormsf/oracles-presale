pragma solidity ^0.4.17;

import '../contracts/PresaleOracles.sol';


contract PresaleOraclesMock is PresaleOracles {
    uint256 mockTime = 0;
    function PresaleOraclesMock() public 
        PresaleOracles()
    {
    }
    // Debug method to redefine current time
    function setTime(uint256 _time) public {
        mockTime = _time;
    }

    function getTime() internal view returns (uint256) {
        if (mockTime != 0) {
            return mockTime;
        } else {
            return now;
        } 
    }
}