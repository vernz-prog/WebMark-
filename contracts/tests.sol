// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IERC721 {
    function transferFrom(address _from, address _to, uint _nftId) external;
    function ownerOf(uint tokenId) external view returns (address owner);
}

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool); 
}

contract DutchAuction {

    IERC721 public immutable nft;
    uint public immutable nftId;
    IERC20 public immutable coin;
    uint public immutable startingPrice;
    uint public immutable discountRate;
    uint public immutable duration;

    bool public isCancelled;
    bool public isSold;
    bool public isApproved;
    uint public immutable startAt;
    uint public immutable expiresAt;
    address payable public immutable seller;

    constructor(address _nft, uint _nftId, address _coin, uint _startingPrice, uint _endPrice, uint _duration) {
        require(_startingPrice >= _endPrice, "starting price < min");    
        seller = payable(msg.sender);
        nft = IERC721(_nft);
        require(nft.ownerOf(_nftId) == msg.sender, "you must be a NFT owner");
        nftId = _nftId;
        coin = IERC20(_coin);
        startingPrice = _startingPrice;
        duration = _duration * (1 hours);
        startAt = block.timestamp;
        expiresAt = block.timestamp + duration;
        discountRate = (_startingPrice - _endPrice) / duration;
        
    }

    function getRemainingTime() external view returns (uint) {
        uint timeStamp = block.timestamp;
        if(timeStamp > expiresAt)
            timeStamp = expiresAt;
        return uint((expiresAt - timeStamp));
    }

    function getPrice() public view returns (uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function getAddress() external view returns (address) {
        return address(this);
    }

    function buyWithNormal(uint amount) external {
        require(block.timestamp < expiresAt, "auction expired");
        require(!isCancelled, "auction is cancelled by NFT owner");
        require(isApproved, "NFT is not approved to this contract");
        uint price = getPrice();
        require(amount >= price, "ETH < price");
        isSold = true;

        nft.transferFrom(seller, msg.sender, nftId);
        bool result = coin.transferFrom(msg.sender, seller, price);
        require(result, "Failed to send Ether");
    }

    function buyWithNative() external payable {
        require(block.timestamp < expiresAt, "auction expired");
        require(!isCancelled, "auction is cancelled by NFT owner");
        require(isApproved, "NFT is not approved to this contract");
        uint price = getPrice();
        require(msg.value >= price, "ETH < price");
        isSold = true;

        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        seller.transfer(price);
    }

    function cancelAuction() external {
        require(msg.sender == seller, "only NFT owner can call this function");
        isCancelled = true;
    }

    function setApprovalState() external {
        require(msg.sender == seller, "only NFT owner can call this function");
        isApproved = true;
    }
}
