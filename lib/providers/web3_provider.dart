import 'package:flutter/material.dart';
import 'package:katya/services/blockchain_service.dart';
import 'package:katya/services/web3_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

class Web3Provider extends ChangeNotifier {
  final Web3Service _web3Service = Web3Service();

  // Supported chain IDs
  static const List<int> SUPPORTED_CHAIN_IDS = [1, 137, 56, 43114]; // Ethereum, Polygon, BSC, Avalanche
  static const Map<int, String> NETWORK_NAMES = {
    1: 'Ethereum',
    137: 'Polygon',
    56: 'BSC',
    43114: 'Avalanche',
  };
  bool _isConnected = false;
  String? _walletAddress;
  String? _chainId;
  String? _balance;
  BlockchainService? _blockchainService;

  // Getters
  BlockchainService? get blockchainService => _blockchainService;

  // Ethereum address as EthereumAddress object
  EthereumAddress? get ethereumAddress => _walletAddress != null ? EthereumAddress.fromHex(_walletAddress!) : null;

  // Credentials for signing transactions
  Future<Credentials> getCredentials() async {
    if (_walletAddress == null) {
      throw Exception('Wallet not connected');
    }
    return _web3Service.getCredentials();
  }

  // Get current chain ID
  Future<int> getChainId() async {
    if (_chainId == null) {
      throw Exception('Not connected to any network');
    }
    return int.parse(_chainId!);
  }

  bool get isConnected => _isConnected;
  String? get walletAddress => _walletAddress;
  String? get chainId => _chainId;
  String? get balance => _balance;

  Future<void> init() async {
    await _web3Service.initialize();
    if (_web3Service.isConnected) {
      _isConnected = true;
      _walletAddress = _web3Service.currentAddress;
      _chainId = _web3Service.currentChainId;

      // Initialize blockchain service if wallet is connected
      if (_walletAddress != null) {
        _blockchainService = BlockchainService(this);
      }

      await _updateBalance();
      notifyListeners();
    }
  }

  Future<void> connectWallet() async {
    try {
      await _web3Service.connectWallet();
      if (_web3Service.isConnected) {
        _isConnected = true;
        _walletAddress = _web3Service.currentAddress;
        _chainId = _web3Service.currentChainId;

        // Initialize blockchain service after wallet connection
        if (_walletAddress != null) {
          _blockchainService = BlockchainService(this);

          // Save wallet connection state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('walletAddress', _walletAddress!);
          await prefs.setString('chainId', _chainId ?? '');
        }

        await _updateBalance();
        notifyListeners();
      }
    } catch (e) {
      print('Error connecting wallet: $e');
      rethrow;
    }
  }

  Future<void> disconnectWallet() async {
    try {
      await _web3Service.disconnectWallet();
      _isConnected = false;
      _walletAddress = null;
      _chainId = null;
      _balance = null;
      _blockchainService = null;

      // Clear saved wallet state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('walletAddress');
      await prefs.remove('chainId');

      notifyListeners();
    } catch (e) {
      print('Error disconnecting wallet: $e');
      rethrow;
    }
  }

  Future<String> signMessage(String message) async {
    try {
      return await _web3Service.signMessage(message);
    } catch (e) {
      print('Error signing message: $e');
      rethrow;
    }
  }

  /// Checks if the current network is supported
  bool isSupportedNetwork() {
    if (_chainId == null) return false;
    return SUPPORTED_CHAIN_IDS.contains(int.parse(_chainId!));
  }

  /// Switches to a supported network
  Future<bool> switchNetwork(int chainId) async {
    try {
      final success = await _web3Service.switchNetwork(chainId);
      if (success) {
        _chainId = chainId.toString();
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error switching network: $e');
      return false;
    }
  }

  /// Gets the current network name
  String? getNetworkName() {
    if (_chainId == null) return null;
    return NETWORK_NAMES[int.parse(_chainId!)];
  }

  Future<void> _updateBalance() async {
    try {
      final balance = await _web3Service.getBalance();
      final ethBalance = balance / BigInt.from(10).pow(18);
      _balance = '${ethBalance.toStringAsFixed(4)} ETH';
      notifyListeners();
    } catch (e) {
      print('Error updating balance: $e');
    }
  }

  // Add a method to get the Web3Service instance if needed
  Web3Service get web3Service => _web3Service;
}
