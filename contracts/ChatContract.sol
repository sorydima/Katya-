// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ChatContract
 * @dev A smart contract for decentralized message storage and validation
 */
contract ChatContract {
    // Struct to represent a message
    struct Message {
        address sender;
        string roomId;
        string content;
        uint256 timestamp;
        string messageId;
        bool isEdited;
        string[] edits; // History of edits
    }

    // Mapping from message ID to Message
    mapping(string => Message) public messages;
    
    // Mapping from room ID to message IDs
    mapping(string => string[]) public roomMessages;
    
    // Mapping from user address to their message IDs
    mapping(address => string[]) public userMessages;
    
    // Mapping to track room members
    mapping(string => mapping(address => bool)) public roomMembers;
    
    // Mapping to track room admins
    mapping(string => mapping(address => bool)) public roomAdmins;
    
    // Mapping to track banned users per room
    mapping(string => mapping(address => bool)) public bannedUsers;
    
    // Events
    event MessageSent(
        string indexed messageId,
        address indexed sender,
        string indexed roomId,
        string content,
        uint256 timestamp
    );
    
    event MessageEdited(
        string indexed messageId,
        string newContent,
        uint256 editTimestamp
    );
    
    event MessageDeleted(
        string indexed messageId,
        address indexed deletedBy,
        uint256 timestamp
    );
    
    event RoomCreated(
        string indexed roomId,
        address indexed creator
    );
    
    event UserBanned(
        string indexed roomId,
        address indexed user,
        address indexed bannedBy,
        uint256 timestamp
    );
    
    event UserUnbanned(
        string indexed roomId,
        address indexed user,
        address indexed unbannedBy,
        uint256 timestamp
    );
    
    // Modifiers
    modifier onlyRoomAdmin(string memory roomId) {
        require(
            roomAdmins[roomId][msg.sender],
            "Only room admin can perform this action"
        );
        _;
    }
    
    modifier onlyRoomMember(string memory roomId) {
        require(
            roomMembers[roomId][msg.sender] && !bannedUsers[roomId][msg.sender],
            "You are not a member of this room or are banned"
        );
        _;
    }
    
    modifier onlyMessageSender(string memory messageId) {
        require(
            messages[messageId].sender == msg.sender,
            "Only the message sender can perform this action"
        );
        _;
    }
    
    /**
     * @dev Send a message to a room
     * @param roomId The ID of the room
     * @param content The message content
     * @param messageId A unique ID for the message
     */
    function sendMessage(
        string calldata roomId,
        string calldata content,
        string calldata messageId
    ) external onlyRoomMember(roomId) {
        require(bytes(content).length > 0, "Message content cannot be empty");
        require(bytes(messageId).length > 0, "Message ID cannot be empty");
        require(messages[messageId].sender == address(0), "Message ID already exists");
        
        // Create and store the message
        messages[messageId] = Message({
            sender: msg.sender,
            roomId: roomId,
            content: content,
            timestamp: block.timestamp,
            messageId: messageId,
            isEdited: false,
            edits: new string[](0)
        });
        
        // Update room and user message lists
        roomMessages[roomId].push(messageId);
        userMessages[msg.sender].push(messageId);
        
        emit MessageSent(
            messageId,
            msg.sender,
            roomId,
            content,
            block.timestamp
        );
    }
    
    /**
     * @dev Edit an existing message
     * @param messageId The ID of the message to edit
     * @param newContent The new content of the message
     */
    function editMessage(
        string calldata messageId,
        string calldata newContent
    ) external onlyMessageSender(messageId) {
        require(bytes(newContent).length > 0, "New content cannot be empty");
        
        Message storage message = messages[messageId];
        
        // Save the old content to edits history
        message.edits.push(message.content);
        
        // Update the message
        message.content = newContent;
        message.isEdited = true;
        
        emit MessageEdited(
            messageId,
            newContent,
            block.timestamp
        );
    }
    
    /**
     * @dev Delete a message (soft delete by clearing content)
     * @param messageId The ID of the message to delete
     */
    function deleteMessage(
        string calldata messageId
    ) external onlyMessageSender(messageId) {
        Message storage message = messages[messageId];
        
        // Save the message content to edits before clearing
        message.edits.push(message.content);
        
        // Clear the message content
        message.content = "[deleted]";
        
        emit MessageDeleted(
            messageId,
            msg.sender,
            block.timestamp
        );
    }
    
    /**
     * @dev Create a new room
     * @param roomId The ID of the new room
     */
    function createRoom(string calldata roomId) external {
        require(bytes(roomId).length > 0, "Room ID cannot be empty");
        require(roomMessages[roomId].length == 0, "Room already exists");
        
        // Add the creator as the first member and admin
        roomMembers[roomId][msg.sender] = true;
        roomAdmins[roomId][msg.sender] = true;
        
        emit RoomCreated(roomId, msg.sender);
    }
    
    /**
     * @dev Add a member to a room
     * @param roomId The ID of the room
     * @param member The address of the member to add
     */
    function addRoomMember(
        string calldata roomId,
        address member
    ) external onlyRoomAdmin(roomId) {
        require(!roomMembers[roomId][member], "User is already a member");
        require(!bannedUsers[roomId][member], "User is banned from this room");
        
        roomMembers[roomId][member] = true;
    }
    
    /**
     * @dev Ban a user from a room
     * @param roomId The ID of the room
     * @param user The address of the user to ban
     */
    function banUser(
        string calldata roomId,
        address user
    ) external onlyRoomAdmin(roomId) {
        require(user != msg.sender, "Cannot ban yourself");
        require(roomMembers[roomId][user], "User is not a member");
        
        bannedUsers[roomId][user] = true;
        
        emit UserBanned(
            roomId,
            user,
            msg.sender,
            block.timestamp
        );
    }
    
    /**
     * @dev Unban a user from a room
     * @param roomId The ID of the room
     * @param user The address of the user to unban
     */
    function unbanUser(
        string calldata roomId,
        address user
    ) external onlyRoomAdmin(roomId) {
        require(bannedUsers[roomId][user], "User is not banned");
        
        bannedUsers[roomId][user] = false;
        
        emit UserUnbanned(
            roomId,
            user,
            msg.sender,
            block.timestamp
        );
    }
    
    /**
     * @dev Get messages for a room with pagination
     * @param roomId The ID of the room
     * @param offset The starting index for pagination
     * @param limit The maximum number of messages to return
     * @return An array of message structs
     */
    function getRoomMessages(
        string calldata roomId,
        uint256 offset,
        uint256 limit
    ) external view returns (Message[] memory) {
        string[] storage messageIds = roomMessages[roomId];
        uint256 totalMessages = messageIds.length;
        
        if (offset >= totalMessages) {
            return new Message[](0);
        }
        
        uint256 end = offset + limit;
        if (end > totalMessages) {
            end = totalMessages;
        }
        
        uint256 resultCount = end - offset;
        Message[] memory result = new Message[](resultCount);
        
        for (uint256 i = 0; i < resultCount; i++) {
            result[i] = messages[messageIds[offset + i]];
        }
        
        return result;
    }
    
    /**
     * @dev Get the edit history of a message
     * @param messageId The ID of the message
     * @return An array of previous message contents
     */
    function getMessageHistory(
        string calldata messageId
    ) external view returns (string[] memory) {
        return messages[messageId].edits;
    }
}
