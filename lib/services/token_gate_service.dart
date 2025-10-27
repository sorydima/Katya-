import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:katya/models/token_gate_config.dart';
import 'package:katya/models/token_gate_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

class TokenGateService {
  static const String _cacheKeyPrefix = 'token_gate_cache_';
  static const Duration _defaultCacheDuration = Duration(hours: 1);
  static TokenGateService? _instance;

  // ERC20 ABI
  static const String _erc20Abi = '''
    [
      {
        "constant": true,
        "inputs": [{"name": "_owner", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"name": "balance", "type": "uint256"}],
        "type": "function"
      }
    ]
  ''';

  // ERC721 ABI
  static const String _erc721Abi = '''
    [
      {
        "constant": true,
        "inputs": [{"name": "_owner", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"name": "", "type": "uint256"}],
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [{"name": "_tokenId", "type": "uint256"}],
        "name": "ownerOf",
        "outputs": [{"name": "", "type": "address"}],
        "type": "function"
      }
    ]
  ''';

  final Web3Client? _web3client;
  final SharedPreferences? _prefs;
  final Duration cacheDuration;

  // In-memory cache for faster access
  final Map<String, ({bool hasAccess, DateTime expiry})> _memoryCache = {};

  TokenGateService({
    Web3Client? web3client,
    SharedPreferences? prefs,
    this.cacheDuration = _defaultCacheDuration,
  })  : _web3client = web3client,
        _prefs = prefs;

  /// Checks if the given address has access based on the token gate configuration
  Future<bool> checkAccess({
    required String address,
    required TokenGateConfig config,
    bool useCache = true,
  }) async {
    if (!config.isEnabled) return true;

    final cacheKey = '$_cacheKeyPrefix${config.id}';
    final now = DateTime.now();

    // Check memory cache first
    if (useCache && _memoryCache.containsKey(cacheKey)) {
      final cached = _memoryCache[cacheKey]!;
      if (now.isBefore(cached.expiry)) {
        return cached.hasAccess;
      }
    }

    // Check persistent cache if available
    if (useCache && _prefs != null && _prefs!.containsKey(cacheKey)) {
      try {
        final cached = jsonDecode(_prefs!.getString(cacheKey)!);
        final expiry = DateTime.parse(cached['expiry'] as String);

        if (now.isBefore(expiry)) {
          final hasAccess = cached['hasAccess'] as bool;
          _updateMemoryCache(cacheKey, hasAccess);
          return hasAccess;
        }
      } catch (e) {
        developer.log('Error reading from cache: $e', name: 'TokenGateService');
      }
    }

    bool hasAccess = false;

    try {
      switch (config.type) {
        case TokenGateType.nft:
          hasAccess = await _checkNftAccess(address, config);
        case TokenGateType.token:
          hasAccess = await _checkTokenAccess(address, config);
        case TokenGateType.premium:
          hasAccess = await _checkPremiumAccess(address, config);
        default:
          hasAccess = false;
      }

      // Update caches
      _updateCaches(cacheKey, hasAccess);

      return hasAccess;
    } catch (e) {
      developer.log('Error checking token access: $e', name: 'TokenGateService');
      // Return the last known good value from cache if available
      return _memoryCache[cacheKey]?.hasAccess ?? false;
    }
  }

  Future<bool> _checkNftAccess(String address, TokenGateConfig config) async {
    if (config.contractAddress == null) return false;

    try {
      final contractAddress = EthereumAddress.fromHex(config.contractAddress!);
      final userAddress = EthereumAddress.fromHex(address);

      if (_web3client == null) {
        throw Exception('Web3Client not initialized');
      }

      if (config.tokenId != null) {
        // Check ownership of specific token ID
        final contract = _getErc721Contract(contractAddress);
        final owner = await _web3client!.call(
          contract: contract,
          function: contract.function('ownerOf'),
          params: [BigInt.parse(config.tokenId!)],
        );
        return (owner[0] as EthereumAddress).hex == userAddress.hex;
      } else {
        // Check balance of any token from the collection
        final contract = _getErc721Contract(contractAddress);
        final balance = await _web3client!.call(
          contract: contract,
          function: contract.function('balanceOf'),
          params: [userAddress],
        );
        final BigInt minBalance = config.minBalance != null ? BigInt.parse(config.minBalance!) : BigInt.one;
        final balanceValue = balance[0] as BigInt;
        return balanceValue >= minBalance;
      }
    } catch (e) {
      developer.log('Error checking NFT access: $e', name: 'TokenGateService');
      return false;
    }
  }

  Future<bool> _checkTokenAccess(String address, TokenGateConfig config) async {
    if (config.contractAddress == null) return false;

    try {
      final contractAddress = EthereumAddress.fromHex(config.contractAddress!);
      final userAddress = EthereumAddress.fromHex(address);

      if (_web3client == null) {
        throw Exception('Web3Client not initialized');
      }

      final contract = _getErc20Contract(contractAddress);
      final balance = await _web3client!.call(
        contract: contract,
        function: contract.function('balanceOf'),
        params: [userAddress],
      );

      final BigInt minBalance = config.minBalance != null ? BigInt.parse(config.minBalance!) : BigInt.zero;
      final balanceValue = balance[0] as BigInt;
      return balanceValue >= minBalance;
    } catch (e) {
      developer.log('Error checking token access: $e', name: 'TokenGateService');
      return false;
    }
  }

  Future<bool> _checkPremiumAccess(String address, TokenGateConfig config) async {
    // Implement premium access logic (e.g., check subscription status)
    // This could be a backend API call or a smart contract check
    return false;
  }

  DeployedContract _getErc20Contract(EthereumAddress contractAddress) {
    return DeployedContract(
      ContractAbi.fromJson(TokenGateService._erc20Abi, 'ERC20'),
      contractAddress,
    );
  }

  DeployedContract _getErc721Contract(EthereumAddress contractAddress) {
    return DeployedContract(
      ContractAbi.fromJson(TokenGateService._erc721Abi, 'ERC721'),
      contractAddress,
    );
  }

  void _updateMemoryCache(String key, bool hasAccess) {
    _memoryCache[key] = (
      hasAccess: hasAccess,
      expiry: DateTime.now().add(cacheDuration),
    );
  }

  Future<void> _updateCaches(String key, bool hasAccess) async {
    final expiry = DateTime.now().add(cacheDuration);

    // Update memory cache
    _updateMemoryCache(key, hasAccess);

    // Update persistent cache if available
    if (_prefs != null) {
      await _prefs!.setString(
        key,
        jsonEncode({
          'hasAccess': hasAccess,
          'expiry': expiry.toIso8601String(),
          'checkedAt': DateTime.now().toIso8601String(),
        }),
      );
    }
  }

  // Clear the cache
  void clearCache() {
    _memoryCache.clear();
  }

  // Clear a specific entry from cache
  void clearCacheForAddress(String address) {
    _memoryCache.removeWhere((key, _) => key.startsWith('$address-'));
  }

  /// Gets or creates the singleton instance of TokenGateService
  static Future<TokenGateService> getInstance() async {
    if (_instance != null) return _instance!;

    // Initialize with default values
    final prefs = await SharedPreferences.getInstance();

    _instance = TokenGateService(
      web3client: Web3Client(
        const String.fromEnvironment('RPC_URL', defaultValue: 'https://mainnet.infura.io/v3/YOUR-PROJECT-ID'),
        http.Client(),
      ),
      prefs: prefs,
    );

    return _instance!;
  }
}
