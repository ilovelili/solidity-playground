// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract Twitter {
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 createdAt;
    }
    
    struct Message {
        uint256 id;
        string content;
        address from;
        address to;
        uint256 createdAt;
    }
    
    mapping(uint256 => Tweet) private tweets;
    mapping(address => uint256[]) private tweetsOf;
    mapping(uint256 => Message[]) private conversations;
    mapping(address => address[]) private following;
    mapping(address => mapping(address => bool)) private operators;
    
    uint256 nextTweetId;
    uint256 nextMessageId;
    
    event TweetSent (
        uint256 indexed id,
        address indexed author,
        string content,
        uint256 createdAt
    );
    
    event MessageSent (
        uint256 indexed id,
        string content,
        address indexed from,
        address indexed to,
        uint256 createdAt
    );
    
    function tweet(string calldata content) external {
        _tweet(msg.sender, content);
    }
    
    function tweetFrom(address from, string calldata content) external {
        _tweet(from, content);
    }
    
    function sendMessage(address to, string calldata content) external {
        _sendMessage(content, msg.sender, to);
    }
    
    function sendMessageFrom(address from, address to, string calldata content) external {
        _sendMessage(content, from, to);
    }
    
    function follow(address followed) external {
        following[msg.sender].push(followed);
    }
    
    function getLatestTweets(uint256 count) view external returns(Tweet[] memory) {
        require(count > 0 && count <= nextTweetId, 'Invalud count');
        Tweet[] memory _tweets = new Tweet[](count);
        for (uint256 i = 0; i < count; i++) {
            uint index = nextTweetId - count + i;
            Tweet memory _tweet = tweets[index];
            _tweets[i] = _tweet;
        }
        
        return _tweets;
    }
    
    
    function _tweet(address from, string memory content) canOperate(from) private {
        tweets[nextTweetId] = Tweet(nextTweetId, from, content, block.timestamp);
        tweetsOf[msg.sender].push(nextTweetId);
        emit TweetSent(nextTweetId, from, content, block.timestamp);
        nextTweetId++;
    }
    
    function _sendMessage(string memory content, address from, address to) canOperate(from) private {
        uint256 conversationId = uint256(from) + uint256(to);
        conversations[conversationId].push(Message(nextMessageId, content, from, to, block.timestamp));
        emit MessageSent(nextMessageId, content, from, to, block.timestamp);
        nextMessageId++;
    }
    
    modifier canOperate(address from) {
        require(operators[from][msg.sender] == true, 'Operator not authorized');
        _;
    }
}