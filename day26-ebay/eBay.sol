// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// 1. Allow seller to create auctions
// 2. Allow buyers make offer for an auctions
// 3. Allow seller and buyers to trade at the end of an auction
// 4. Create some getter functions for auctions and offers
contract ebay {
    struct Auction {
        uint256 id;
        address payable seller;
        string name;
        string description;
        uint256 min;
        uint256 end;
        uint256 bestOfferId;
        uint256[] offerIds;
    }
    
    struct Offer {
        uint256 id;
        uint256 auctionId;
        address payable buyer;
        uint256 price;
    }
    
    mapping(uint256 => Auction) private auctions;
    mapping(uint256 => Offer) private offers;
    
    mapping(address => uint256[]) private userAuctions;
    mapping(address => uint256[]) private userOffers;
    
    uint256 private nextAuctionId;
    uint256 private nextOfferId;
    
    function createAuction(
        string calldata _name,
        string calldata _description,
        uint _min,
        uint _duration    
    ) external {
        require(_min > 0, "minimum price must be greater than 0");
        require(_duration > 86400 && _duration < 864000, '_duration must be comprised between 1 to 10 days');
        uint256[] memory offerIds = new uint256[](0);
        auctions[nextAuctionId] = Auction(nextAuctionId, msg.sender, _name, _description, _min, _duration, 0, offerIds);
        
        userAuctions[msg.sender].push(nextAuctionId);
        nextAuctionId++;
    }
    
    function createOffer(uint256 _auctionId) external payable auctionExists(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        Offer storage bestOffer = offers[auction.bestOfferId];
        require(block.timestamp < auction.end, "Auction expired");
        require(msg.value >= auction.min && msg.value > bestOffer.price, 'msg.value must be superior to min and bestOffer');
        auction.bestOfferId = nextOfferId;
        auction.offerIds.push(nextOfferId);
        offers[nextOfferId] = Offer(nextOfferId, auction.id, msg.sender, msg.value);
        userOffers[msg.sender].push(nextOfferId);
        nextOfferId++;
    }
    
    function trade(uint _auctionId) external auctionExists(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(block.timestamp > auction.end, "Auction is still alive. Cannot trade");
        for (uint256 i = 0; i < auction.offerIds.length; i++) {
            uint256 offerId = auction.offerIds[i];
            // return the money
            if (offerId != auction.bestOfferId) {
                Offer storage offer = offers[offerId];
                offer.buyer.transfer(offer.price);
            }
        }
        Offer storage bestOffer = offers[auction.bestOfferId];
        auction.seller.transfer(bestOffer.price);
    }
    
    function getAuctions() view external returns (Auction[] memory) {
        Auction[] memory _auctions = new Auction[](nextAuctionId);
        for (uint256 i  = 0; i < nextAuctionId; i++) {
            _auctions[i] = auctions[i];
        }
        
        return _auctions;
    }
    
    function getUserAuctions(address _user) view external returns(Auction[] memory) {
        uint256[] storage userAuctionIds = userAuctions[_user];
        Auction[] memory _auctions = new Auction[](userAuctionIds.length);
        for (uint256 i = 0; i < userAuctionIds.length; i++) {
            uint256 auctionId = userAuctionIds[i];
            _auctions[i] = auctions[auctionId];
        }
        return _auctions;
    }
    
    function getUserOffers(address _user) view external returns(Offer[] memory) {
        uint[] storage userOfferIds = userOffers[_user];
        Offer[] memory _offers = new Offer[](userOfferIds.length);
        for(uint i = 0; i < userOfferIds.length; i++) {
            uint offerId = userOfferIds[i];
            _offers[i] = offers[offerId];
        }
        return _offers;
    }
    
    modifier auctionExists(uint256 _auctionId) {
        require(_auctionId > 0 && _auctionId < nextAuctionId, 'Auction does not exist');
        _;
    }
}