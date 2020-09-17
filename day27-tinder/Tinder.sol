// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// 1. Register User
// 2. Matching: swipe right / left
// 3. Messaging: send messages to matches
contract tinder {
    enum Gender {
        Female,
        Male
    }
    
    enum SwipeStatus {
        Unknown,
        Like,
        Dislike
    }
    
    struct User {
        string name;
        string city;
        Gender gender;
        uint256 age;
        string picURL;
    }
    
    struct SwipeSession {
        uint256 start;
        uint256 count;
    }
    
    mapping(address => User) private users;
    mapping(bytes32 /*city*/ => mapping(uint256 /*gender*/ => address[] /*user id*/)) private userIdsByCity;
    mapping(address => mapping(address => SwipeStatus)) private swipes;
    mapping(address => SwipeSession) private swipeSessions;
    
    event NewMatch(
        address indexed from,
        address indexed to,
        uint256 date
    );
    
    event NewMessage(
        address indexed from,
        address indexed to,
        string content,
        uint256 date
    );
    
    function register(
        string calldata _name,
        string calldata _city,
        Gender _gender,
        uint _age,
        string calldata _picURL)
        external {
            require(users[msg.sender].age == 0, "User already registered");
            require(!_isEmptyString(_name), '_name cannot be empty');
            require(!_isEmptyString(_city), '_city cannot be empty');
            require(_age > 17, '_age must be 18 or above');
            require(!_isEmptyString(_picURL), '_picURL cannot be empty');
            users[msg.sender] = User(_name, _city, _gender, _age, _picURL);
            userIdsByCity[keccak256(abi.encodePacked(_city))][uint256(_gender)].push(msg.sender);
        }
        
    function getMatchableUsers() 
        view
        external
        userExists(msg.sender)
        returns(User[] memory ) {
            User storage user = users[msg.sender];
            uint256 oppositeGender = user.gender == Gender.Female ? uint256(Gender.Male) : uint256(Gender.Female);
            address[] storage userIds = userIdsByCity[keccak256(abi.encodePacked(user.city))][oppositeGender];
            
            uint256 matchableUserCount;
            for(uint256 i = 0; i < userIds.length; i++) {
                address userId = userIds[i];
                if(swipes[msg.sender][userId] == SwipeStatus.Unknown) {
                    matchableUserCount++;
                }
            }
            
            User[] memory _users = new User[](matchableUserCount);
            for(uint256 i = 0; i < matchableUserCount; i++) {
                address userId = userIds[i];
                if(swipes[msg.sender][userId] == SwipeStatus.Unknown) {
                    _users[i] = users[userId];
                }
            }
            
            return _users; 
        }
        
    function swipe(SwipeStatus _swipeStatus, address _userId) external userExists(msg.sender) userExists(_userId) {
        require(swipes[msg.sender][_userId] == SwipeStatus.Unknown, 'Cannot swipe the same person twice');
        SwipeSession storage swipeSession = swipeSessions[msg.sender];
        if(swipeSession.start + 86400 <= block.timestamp) {
            swipeSession.start = block.timestamp;
            swipeSession.count = 100;
        }
        
        require(swipeSession.count <= 100, 'You have already used up all your swipes for today');
        swipeSession.count++;
        
        if(_swipeStatus == SwipeStatus.Dislike) {
            swipes[msg.sender][_userId] = _swipeStatus;
            return;
        } 
        swipes[msg.sender][_userId] = SwipeStatus.Like;
        if(swipes[_userId][msg.sender] == SwipeStatus.Like) {
            emit NewMatch(msg.sender, _userId, block.timestamp);
        }
    }
    
    function sendMessage(
        address _to, 
        string calldata _content) 
        external
        userExists(msg.sender)
        userExists(_to) {
        require(swipes[msg.sender][_to] == SwipeStatus.Like && swipes[_to][msg.sender] == SwipeStatus.Like, 'Both users need to have liked each other (match) to send messages');
        emit NewMessage(msg.sender, _to, _content, block.timestamp);
    }
    
    function _isEmptyString(string memory input) pure private returns (bool) {
        bytes memory inputBytes = bytes(input);
        return inputBytes.length > 0;
    }
    
     modifier userExists(address _userId) {
        require(users[_userId].age > 0, 'User is not registered');
        _;
    }
    
}