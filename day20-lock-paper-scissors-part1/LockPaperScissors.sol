// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract LockPaperScissors {
    enum State {
        CREATED,
        JOINED
    }
    
    struct Game {
        uint256 id;
        uint256 bet;
        address[] players;
        State state;
    }
    
    mapping(uint256 => Game) games;
    uint256 gameId;
    
    function createGame(address participant) external payable {
        address[] memory players = new address[](2);
        players[0] = msg.sender;
        players[1] = participant;
        games[gameId] = Game(gameId, msg.value, players, State.CREATED);
        gameId++;
    }
    
    function joinGame(uint256 id) external payable {
        Game storage game = games[id];
        require(game.id != 0, "invalid game id");
        require(game.state == State.CREATED, "invalid game state");
        require(msg.value >= game.bet, "not enough bet");
        require(msg.sender == game.players[1], "you are not allowed to join");
        
        if (msg.value > game.bet) {
            msg.sender.transfer(msg.value - game.bet);
        }
        
        game.state = State.JOINED;
    }
    
}