import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:katya/providers/web3_provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class BlockchainService {
  static const String _contractAddress = '0x123...'; // Replace with actual contract address
  static const String _rpcUrl = 'http://127.0.0.1:8545'; // Local testnet or Infura URL
  static const String _wsUrl = 'ws://127.0.0.1:8545/ws'; // WebSocket URL for subscriptions

  late Web3Client _web3client;
  late DeployedContract _contract;
  late ContractFunction _sendMessageFunction;
  late ContractFunction _editMessageFunction;
  late ContractFunction _deleteMessageFunction;
  late ContractFunction _getRoomMessagesFunction;

  final Web3Provider _web3Provider;

  BlockchainService(this._web3Provider) {
    _init();
  }

  Future<void> _init() async {
    // Initialize Web3 client
    _web3client = Web3Client(
      _rpcUrl,
      http.Client(),
      socketConnector: () => IOWebSocketChannel.connect(_wsUrl).cast(),
    );

    // Load contract ABI
    final abi = await _loadContractABI();

    // Initialize contract
    _contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'ChatContract'),
      EthereumAddress.fromHex(_contractAddress),
    );

    // Initialize contract functions
    _sendMessageFunction = _contract.function('sendMessage');
    _editMessageFunction = _contract.function('editMessage');
    _deleteMessageFunction = _contract.function('deleteMessage');
    _getRoomMessagesFunction = _contract.function('getRoomMessages');
  }

  Future<Map<String, dynamic>> _loadContractABI() async {
    // Load ABI from file or network
    // For now, we'll return a simplified ABI
    return {
      'abi': [
        // Send Message
        {
          'inputs': [
            {'internalType': 'string', 'name': 'roomId', 'type': 'string'},
            {'internalType': 'string', 'name': 'content', 'type': 'string'},
            {'internalType': 'string', 'name': 'messageId', 'type': 'string'}
          ],
          'name': 'sendMessage',
          'outputs': [],
          'stateMutability': 'nonpayable',
          'type': 'function'
        },
        // Other ABI definitions...
      ]
    };
  }

  /// Sends a message to a room on the blockchain
  Future<String> sendMessage({
    required String roomId,
    required String content,
    required String messageId,
  }) async {
    try {
      final credentials = await _web3Provider.getCredentials();

      final tx = Transaction.callContract(
        contract: _contract,
        function: _sendMessageFunction,
        parameters: [roomId, content, messageId],
      );

      final txHash = await _web3client.sendTransaction(
        credentials,
        tx,
        chainId: await _web3Provider.getChainId(),
      );

      return txHash;
    } catch (e) {
      print('Error sending message to blockchain: $e');
      rethrow;
    }
  }

  /// Edits an existing message on the blockchain
  Future<String> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      final credentials = await _web3Provider.getCredentials();

      final tx = Transaction.callContract(
        contract: _contract,
        function: _editMessageFunction,
        parameters: [messageId, newContent],
      );

      final txHash = await _web3client.sendTransaction(
        credentials,
        tx,
        chainId: await _web3Provider.getChainId(),
      );

      return txHash;
    } catch (e) {
      print('Error editing message on blockchain: $e');
      rethrow;
    }
  }

  /// Deletes a message (soft delete) on the blockchain
  Future<String> deleteMessage(String messageId) async {
    try {
      final credentials = await _web3Provider.getCredentials();

      final tx = Transaction.callContract(
        contract: _contract,
        function: _deleteMessageFunction,
        parameters: [messageId],
      );

      final txHash = await _web3client.sendTransaction(
        credentials,
        tx,
        chainId: await _web3Provider.getChainId(),
      );

      return txHash;
    } catch (e) {
      print('Error deleting message on blockchain: $e');
      rethrow;
    }
  }

  /// Fetches messages for a room from the blockchain
  Future<List<Map<String, dynamic>>> getRoomMessages({
    required String roomId,
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      final result = await _web3client.call(
        contract: _contract,
        function: _getRoomMessagesFunction,
        params: [roomId, BigInt.from(offset), BigInt.from(limit)],
      );

      // Convert the result to a list of message maps
      final List<dynamic> messages = result[0];
      return messages.map((msg) => _parseMessage(msg)).toList();
    } catch (e) {
      print('Error fetching messages from blockchain: $e');
      return [];
    }
  }

  /// Parses a message from the blockchain into a Dart map
  Map<String, dynamic> _parseMessage(dynamic message) {
    return {
      'sender': message[0].toString(),
      'roomId': message[1],
      'content': message[2],
      'timestamp': (message[3] as BigInt).toInt(),
      'messageId': message[4],
      'isEdited': message[5],
      'edits': List<String>.from(message[6]),
    };
  }

  /// Listens for new messages in a room
  Stream<Map<String, dynamic>> messageStream(String roomId) {
    // Create a filter for the MessageSent event
    final event = _contract.event('MessageSent');

    return _web3client
        .events(FilterOptions.events(
          contract: _contract,
          event: event,
        ))
        .map((event) {
          // Filter for the specific room
          if (event.topics != null && event.topics!.length > 2) {
            final eventRoomId = event.topics![2];
            if (eventRoomId == roomId) {
              return _parseMessage(event.data);
            }
          }
          return null;
        })
        .where((message) => message != null)
        .cast<Map<String, dynamic>>();
  }

  /// Verifies if a message is valid on the blockchain
  Future<bool> verifyMessage({
    required String messageId,
    required String content,
    required String sender,
  }) async {
    try {
      final result = await _web3client.call(
        contract: _contract,
        function: _contract.function('messages'),
        params: [messageId],
      );

      final message = _parseMessage(result);
      return message['content'] == content && message['sender'] == sender.toLowerCase();
    } catch (e) {
      print('Error verifying message on blockchain: $e');
      return false;
    }
  }
}
