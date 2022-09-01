//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address payable public manager;
    address payable[] public participants;

    constructor() {
        manager = payable(msg.sender);
    }

    //Below modifier is used to allow only the manager to use a certain function
    modifier isManager {
        require(msg.sender == manager, "Only the manager has the authority to use this function");
        _;
    }

    /*
    We need the contract to recieve funds in the form of ether and each time the contract is
    called, it should recieve ether only once as ether should be recieved only once when the
    lottery is bought. If ether is recieved successfully, i.e. the lottery is bought, add the 
    participant in the array.
    */
    receive() external payable {
        //Below line indicates that the function is executed further only if the participant sends 0.5 ether
        require(msg.value == 1 ether, "Lottery ticket costs 0.5 ether!");
        participants.push(payable(msg.sender));
    }

    //Below function is used to know the amount of ether that are present in contract's fund
    function getBalance() public isManager view returns(uint) {
        return address(this).balance;
    }

    //Below function returns a randomly generated uint value based on the participants list
    function random() internal isManager view returns(uint) {
        /*
        participants.length: Length of the participants list
        block.timestamp: Time at which the block was added to the blockchain
        block.difficulty: Difficulty of the block to be mined at the moment
        abi.encodePacked(arg): Used to simply concatenate the arguments into one without spaces
        keccak256: Hashing algorithm

        As all the above factors keep changing, the randomness increases, hence it is used to 
        generate a random number which cant be predicted.
        */
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    //Below function is used to select a winner and initiate the reward
    function selectWinner() public isManager {
        require(participants.length >= 3, "Minumum 3 participants are required!");
        uint randomValue = random();
        address payable winner;
        uint index = randomValue % participants.length;
        winner = participants[index];
        initiateTransaction(winner);
    }

    //Below function is used to transfer ether to the winner's address and an incentive to the manager
    function initiateTransaction(address payable _winner) internal {
        uint balance = getBalance();
        uint div = 100;
        uint mul = 5;
        uint incentive = balance / div * mul;
        balance = balance - incentive;
        _winner.transfer(balance);
        manager.transfer(incentive);
        //After the reward has been given, empty the participant list for next lottery session
        participants = new address payable[](0);
    }
}