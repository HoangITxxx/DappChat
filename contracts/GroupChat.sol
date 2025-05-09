pragma solidity ^0.8.0;
import "./UserInbox.sol";

contract GroupChat {
    address public admin;
    string public groupPublicKey;
    string private encryptedGroupPrivateKey;

    struct Member{
        address memberAddress;
        string publicKey;
    }
    struct Message{
        address sender;
        string encryptedContent; 
        uint timestamp;
    }
    Member[] public members;
    Message[] private messages;

mapping(address => bool) public isMember;

    constructor(address _admin, string memory _groupPublicKey, string memory _encryptedGroupPrivateKey) {
        admin = _admin;
        groupPublicKey = _groupPublicKey;
        encryptedGroupPrivateKey = _encryptedGroupPrivateKey;
        members.push(Member(_admin, ""));
        isMember[_admin] = true;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call!!!");
        _;
    }

    modifier onlyMember() {
        require(isMember[msg.sender], "You are Not a member");
        _;
    }

    function addMember(address _memberAddress, string memory _memberPublicKey) external onlyAdmin {
        require(!isMember[_memberAddress], "Member already exists");
        members.push(Member(_memberAddress, _memberPublicKey));
        isMember[_memberAddress] = true;
        emit MemberAdded(_memberAddress, _memberPublicKey);
    }

    function getMembers() external view returns (Member[] memory) {
        return members;
    }

    function getEncryptedGroupPrivateKey() external view onlyAdmin returns (string memory) {
        return encryptedGroupPrivateKey;
    }

    function sendMessage(string memory _encryptedContent) external onlyMember {
        messages.push(Message({
            sender: msg.sender,
            encryptedContent: _encryptedContent,
            timestamp: block.timestamp
        }));
        emit MessageSent(msg.sender, _encryptedContent, block.timestamp);
    }

    function getMessages() external view onlyMember returns (Message[] memory) {
        return messages;
    }

    event MemberAdded(address indexed memberAddress, string publicKey);
    event MessageSent(address indexed sender, string encryptedContent, uint timestamp);
}