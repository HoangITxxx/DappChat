// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserInbox {
    address public owner;
    string public publicKey;
    string private encryptedPrivateKey;

    struct Message {
        address sender;
        string encryptedContent;
        uint timestamp;
        bool isRead;
    }

    Message[] private messages;

    constructor(address _owner, string memory _publicKey, string memory _encryptedPrivateKey) {
        owner = _owner;
        publicKey = _publicKey;
        encryptedPrivateKey = _encryptedPrivateKey;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function getEncryptedPrivateKey() external view onlyOwner returns (string memory) {
        return encryptedPrivateKey;
    }

    function getPublicKey() external view returns (string memory) {
        return publicKey;
    }

    function getMessages() external view onlyOwner returns (Message[] memory) {
        return messages;
    }

    function sendMessage(string memory _encryptedContent) external {
        messages.push(Message({
            sender: msg.sender,
            encryptedContent: _encryptedContent,
            timestamp: block.timestamp,
            isRead: false
        }));

        emit MessageReceived(msg.sender, _encryptedContent, block.timestamp);
    }
    event MessageReceived(address indexed from, string encryptedContent, uint timestamp);
}
