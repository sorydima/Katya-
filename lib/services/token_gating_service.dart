import 'package:http/http.dart' as http;
import 'package:katya/global/constants.dart';
import 'package:katya/providers/web3_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

class TokenGatingService {
  final Web3Provider _web3Provider;
  final String _rpcUrl;
  late Web3Client _web3client;

  TokenGatingService(this._web3Provider, {String? rpcUrl}) : _rpcUrl = rpcUrl ?? DEFAULT_RPC_URL {
    _web3client = Web3Client(_rpcUrl, http.Client());
  }

  /// Checks if the current user meets all token requirements for a room
  Future<bool> checkRoomAccess(String roomId) async {
    try {
      // Get the contract instance
      final contract = await _getContract();

      // Call the checkTokenRequirements function
      final result = await _web3client.call(
        contract: contract,
        function: contract.function('checkTokenRequirements'),
        params: [roomId, _web3Provider.ethereumAddress],
      );

      return result[0] as bool;
    } catch (e) {
      print('Error checking room access: $e');
      return false;
    }
  }

  /// Gets the token requirements for a room
  Future<List<Map<String, dynamic>>> getRoomTokenRequirements(String roomId) async {
    try {
      final contract = await _getContract();
      final requirements = <Map<String, dynamic>>[];

      // Get the number of requirements for this room
      final count = await _web3client.call(
        contract: contract,
        function: contract.function('getTokenRequirementCount'),
        params: [roomId],
      );

      final requirementCount = (count[0] as BigInt).toInt();

      // Get each requirement
      for (int i = 0; i < requirementCount; i++) {
        final requirement = await _web3client.call(
          contract: contract,
          function: contract.function('getTokenRequirement'),
          params: [roomId, BigInt.from(i)],
        );

        requirements.add({
          'tokenAddress': requirement[0],
          'amount': requirement[1],
          'tokenType': requirement[2],
        });
      }

      return requirements;
    } catch (e) {
      print('Error getting token requirements: $e');
      return [];
    }
  }

  /// Adds a token requirement to a room
  Future<String> addTokenRequirement({
    required String roomId,
    required String tokenAddress,
    required BigInt amount,
    required int tokenType,
  }) async {
    try {
      final contract = await _getContract();
      final credentials = await _web3Provider.getCredentials();

      final tx = Transaction.call(
        contract: contract,
        function: contract.function('addTokenRequirement'),
        parameters: [roomId, tokenAddress, amount, tokenType],
      );

      final txHash = await _web3client.sendTransaction(
        credentials,
        tx,
        chainId: await _web3Provider.getChainId(),
      );

      return txHash;
    } catch (e) {
      print('Error adding token requirement: $e');
      rethrow;
    }
  }

  /// Removes a token requirement from a room
  Future<String> removeTokenRequirement({
    required String roomId,
    required int index,
  }) async {
    try {
      final contract = await _getContract();
      final credentials = await _web3Provider.getCredentials();

      final tx = Transaction.call(
        contract: contract,
        function: contract.function('removeTokenRequirement'),
        parameters: [roomId, BigInt.from(index)],
      );

      final txHash = await _web3client.sendTransaction(
        credentials,
        tx,
        chainId: await _web3Provider.getChainId(),
      );

      return txHash;
    } catch (e) {
      print('Error removing token requirement: $e');
      rethrow;
    }
  }

  /// Gets the contract instance
  Future<DeployedContract> _getContract() async {
    // Load contract ABI
    final abi = await _loadContractABI();

    // Get contract address from storage or config
    final prefs = await SharedPreferences.getInstance();
    final contractAddress = prefs.getString('chatContractAddress') ?? CHAT_CONTRACT_ADDRESS;

    return DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'ChatContract'),
      EthereumAddress.fromHex(contractAddress),
    );
  }

  /// Loads the contract ABI
  Future<Map<String, dynamic>> _loadContractABI() async {
    // In a real app, load this from a file or network
    return {
      'abi': [
        // Check token requirements
        {
          'inputs': [
            {'name': 'roomId', 'type': 'string'},
            {'name': 'user', 'type': 'address'}
          ],
          'name': 'checkTokenRequirements',
          'outputs': [
            {'name': '', 'type': 'bool'}
          ],
          'stateMutability': 'view',
          'type': 'function'
        },
        // Add other ABI definitions as needed
      ]
    };
  }
}
