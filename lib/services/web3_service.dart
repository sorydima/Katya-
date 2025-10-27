import 'dart:async';

import 'package:bip39/bip39.dart' as bip39;
import 'package:web3modal_flutter/web3modal_flutter.dart';

class Web3Service {
  static final Web3Service _instance = Web3Service._internal();
  factory Web3Service() => _instance;
  Web3Service._internal();

  // Web3 and wallet state
  Web3Client? _web3client;
  EthereumAddress? _currentAddress;
  String? _currentChainId;
  W3MService? _web3modal;
  bool _isInitialized = false;

  // Getters
  bool get isConnected => _currentAddress != null;
  String? get currentAddress => _currentAddress?.hexEip55;
  String? get currentChainId => _currentChainId;

  // Initialize Web3Service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Web3Modal
    _web3modal = W3MService(
      projectId: 'YOUR_WALLETCONNECT_PROJECT_ID', // Replace with your WalletConnect project ID
      metadata: const PairingMetadata(
        name: 'Katya DApp',
        description: 'Decentralized Matrix Client',
        url: 'https://katya.wtf',
        icons: ['https://katya.wtf/icon.png'],
      ),
    );

    // Try to restore previous session
    await _restoreSession();
    _isInitialized = true;
  }

  // Connect to wallet
  Future<void> connectWallet() async {
    if (!_isInitialized) await initialize();

    try {
      // TODO: Update to use new Web3Modal API
      // The connect() method has been deprecated in web3modal_flutter 3.3.4
      // await _web3modal?.openModal(context);
      
      // For now, throw unimplemented
      throw UnimplementedError('Web3Modal connect API has changed. Please update implementation.');
      
      // if (_web3modal?.session != null) {
      //   _currentAddress = EthereumAddress.fromHex(_web3modal!.session!.address!);
      //   _currentChainId = _web3modal!.session!.chainId;
      //   await _saveSession();
      // }
    } catch (e) {
      print('Error connecting wallet: $e');
      rethrow;
    }
  }

  // Disconnect wallet
  Future<void> disconnectWallet() async {
    await _web3modal?.disconnect();
    _currentAddress = null;
    _currentChainId = null;
    await _clearSession();
  }

  // Sign message with wallet
  Future<String> signMessage(String message) async {
    if (_web3modal?.session == null) {
      throw Exception('Not connected to wallet');
    }

    try {
      // TODO: Update to use new Web3Modal API
      // The signPersonalMessage() method has been deprecated
      throw UnimplementedError('Web3Modal signPersonalMessage API has changed. Please update implementation.');
    } catch (e) {
      print('Error signing message: $e');
      rethrow;
    }
  }

  // Get credentials for transactions
  Future<Credentials> getCredentials() async {
    // For Web3Modal, credentials are handled internally
    // This is a placeholder - may need adjustment based on implementation
    throw UnimplementedError('getCredentials not implemented for Web3Modal');
  }

  // Switch network
  Future<bool> switchNetwork(int chainId) async {
    if (_web3modal?.session == null) {
      throw Exception('Not connected to wallet');
    }

    try {
      // TODO: Update to use new Web3Modal API
      // The switchChain() method has been deprecated
      throw UnimplementedError('Web3Modal switchChain API has changed. Please update implementation.');
    } catch (e) {
      print('Error switching network: $e');
      return false;
    }
  }

  // Get wallet balance
  Future<BigInt> getBalance() async {
    if (_web3client == null || _currentAddress == null) {
      throw Exception('Not connected to blockchain');
    }

    try {
      final balance = await _web3client!.getBalance(_currentAddress!);
      return balance.getInWei;
    } catch (e) {
      print('Error getting balance: $e');
      rethrow;
    }
  }

  // Generate a new wallet (for non-custodial mode)
  Future<Map<String, String>> generateNewWallet() async {
    try {
      // Generate mnemonic
      final mnemonic = bip39.generateMnemonic();

      // Derive private key from mnemonic
      final seed = bip39.mnemonicToSeed(mnemonic);
      final key = EthPrivateKey.fromHex(seed.sublist(0, 32).map((b) => b.toRadixString(16).padLeft(2, '0')).join(''));

      // Encrypt and store the mnemonic
      await _storeMnemonic(mnemonic);

      return {
        'address': key.address.hexEip55,
        'mnemonic': mnemonic,
        'privateKey': key.privateKey.toString(),
      };
    } catch (e) {
      print('Error generating wallet: $e');
      rethrow;
    }
  }

  // Private methods for session management
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentAddress != null) {
      await prefs.setString('wallet_address', _currentAddress!.hexEip55);
    }
    if (_currentChainId != null) {
      await prefs.setString('chain_id', _currentChainId!);
    }
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('wallet_address');
    final chainId = prefs.getString('chain_id');

    if (address != null) {
      _currentAddress = EthereumAddress.fromHex(address);
    }
    if (chainId != null) {
      _currentChainId = chainId;
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallet_address');
    await prefs.remove('chain_id');
  }

  Future<void> _storeMnemonic(String mnemonic) async {
    // In a real app, use secure storage like Flutter Secure Storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mnemonic', mnemonic);
  }

  Future<String?> _getStoredMnemonic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mnemonic');
  }

  // Clean up resources
  void dispose() {
    _web3client?.dispose();
  }
}
