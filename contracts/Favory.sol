// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UserInbox.sol";

contract Favori {

    bool public isActive;

    mapping(address => address) public userToInbox;

    address[] public allInboxes;
    
    event UserRegistered(address indexed user, address inbox);

    constructor() {
        isActive = true;
    }
    
    modifier onlyActive() {
        require(isActive, "Contract khong hoat dong");
        _;
    }
    
    function registerUser(string memory publicKey, string memory encryptedPrivateKey) 
        external 
        onlyActive 
    {
        require(userToInbox[msg.sender] == address(0), "User da dang ky");
        
        UserInbox inbox = new UserInbox(msg.sender, publicKey, encryptedPrivateKey);
        userToInbox[msg.sender] = address(inbox);
        allInboxes.push(address(inbox));
        
        emit UserRegistered(msg.sender, address(inbox));
    }
    
    function getUserInbox(address user) external view returns (address) {
        return userToInbox[user];
    }
    
    function getAllInboxes() external view returns (address[] memory) {
        return allInboxes;
    }
    
    function toggleActive() external {
        isActive = !isActive;
    }
}