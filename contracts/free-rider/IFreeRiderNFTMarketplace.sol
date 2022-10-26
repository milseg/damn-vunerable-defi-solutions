

interface IFreeRiderNFTMarketplace {
	function offerMany(uint256[] calldata tokenIds, uint256[] calldata prices) external;
    function buyMany(uint256[] calldata tokenIds) external payable;
}