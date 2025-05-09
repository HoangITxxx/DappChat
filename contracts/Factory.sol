// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UserInbox.sol";
import "./GroupChat.sol";

contract Factory {

    struct GroupInfo{
        uint groupId;
        address groupContract;
        address admin;
        string groupPublicKey;
    }

    GroupInfo[] public groups;
    mapping(uint => address) public groupIdToContract;
    uint private nextGroupId = 1;
    
    function createGroup(string memory _groupPublicKey, string memory _encryptedGroupPrivateKey) external {
        address inbox = userToInbox[msg.sender];
    require(inbox != address(0), "Admin chua dang ky");

    string memory adminPublicKey = UserInbox(inbox).getPublicKey();

    GroupChat groupChat = new GroupChat(
        msg.sender,
        address(this),
        _groupPublicKey,
        _encryptedGroupPrivateKey,
        adminPublicKey
    );
        uint groupId = nextGroupId++;
        groups.push(GroupInfo({
            groupId: groupId, 
            groupContract: address(groupChat), 
            admin: msg.sender, 
            groupPublicKey: _groupPublicKey
        }));
        groupIdToContract[groupId] = address (groupChat);
        emit GroupCreated(groupId, address(groupChat), msg.sender);
    }
    event GroupCreated(uint indexed groupId, address indexed groupContract, address admin);

    function getUserPublicKey(address user) external view returns (string memory) {
        address inbox = userToInbox[user];
        require(inbox != address(0), "User chua dang ky");
        return UserInbox(inbox).getPublicKey();
    }

    function getGroups() external view returns (GroupInfo[] memory) {
        return groups;
    }

    function getGroupContract(uint _groupId) external view returns (address) {
        return groupIdToContract[_groupId];
    }
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