import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Сервис для интеграции с блокчейн сетями и децентрализованной верификации
class BlockchainVerificationService {
  static final BlockchainVerificationService _instance = BlockchainVerificationService._internal();

  // Поддерживаемые блокчейн сети
  final Map<String, BlockchainNetwork> _networks = {};
  final Map<String, SmartContract> _contracts = {};

  // Кэш верификаций
  final Map<String, BlockchainVerification> _verificationCache = {};

  // Конфигурация
  static const int _verificationTimeoutSeconds = 30;
  static const int _maxRetries = 3;
  static const double _minConfidenceThreshold = 0.7;

  factory BlockchainVerificationService() => _instance;
  BlockchainVerificationService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _initializeSupportedNetworks();
    await _deploySmartContracts();
    _setupPeriodicVerificationUpdate();
  }

  /// Регистрация идентичности в блокчейне
  Future<BlockchainIdentityRegistration> registerIdentity({
    required String identityId,
    required String protocol,
    required Map<String, dynamic> identityData,
    required String networkId,
    String? privateKey,
  }) async {
    final network = _networks[networkId];
    if (network == null) {
      throw Exception('Network $networkId not supported');
    }

    final contract = _contracts[networkId];
    if (contract == null) {
      throw Exception('Smart contract not deployed on network $networkId');
    }

    try {
      // Создаем хеш идентичности
      final identityHash = _generateIdentityHash(identityId, protocol, identityData);

      // Регистрируем в блокчейне
      final transaction = await _registerOnBlockchain(
        network: network,
        contract: contract,
        identityHash: identityHash,
        identityData: identityData,
        privateKey: privateKey,
      );

      return BlockchainIdentityRegistration(
        identityId: identityId,
        networkId: networkId,
        transactionHash: transaction.hash,
        blockNumber: transaction.blockNumber,
        timestamp: DateTime.now(),
        status: RegistrationStatus.pending,
        verificationLevel: VerificationLevel.basic,
      );
    } catch (e) {
      return BlockchainIdentityRegistration(
        identityId: identityId,
        networkId: networkId,
        transactionHash: '',
        blockNumber: 0,
        timestamp: DateTime.now(),
        status: RegistrationStatus.failed,
        verificationLevel: VerificationLevel.none,
        errorMessage: e.toString(),
      );
    }
  }

  /// Верификация идентичности через блокчейн
  Future<BlockchainVerification> verifyIdentity({
    required String identityId,
    required String networkId,
    required Map<String, dynamic> verificationData,
  }) async {
    final cacheKey = '${identityId}_$networkId';

    if (_verificationCache.containsKey(cacheKey)) {
      final cached = _verificationCache[cacheKey]!;
      if (!_isVerificationExpired(cached)) {
        return cached;
      }
    }

    final network = _networks[networkId];
    if (network == null) {
      throw Exception('Network $networkId not supported');
    }

    try {
      // Получаем данные из блокчейна
      final blockchainData = await _fetchFromBlockchain(network, identityId);

      // Верифицируем данные
      final verificationResult = await _performVerification(
        identityId: identityId,
        blockchainData: blockchainData,
        verificationData: verificationData,
        network: network,
      );

      final verification = BlockchainVerification(
        identityId: identityId,
        networkId: networkId,
        verificationLevel: verificationResult.level,
        confidence: verificationResult.confidence,
        blockchainProof: verificationResult.proof,
        timestamp: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        status: verificationResult.status,
        metadata: verificationResult.metadata,
      );

      _verificationCache[cacheKey] = verification;
      return verification;
    } catch (e) {
      return BlockchainVerification(
        identityId: identityId,
        networkId: networkId,
        verificationLevel: VerificationLevel.none,
        confidence: 0.0,
        blockchainProof: '',
        timestamp: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        status: VerificationStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Получение репутации из блокчейна
  Future<BlockchainReputation> getBlockchainReputation({
    required String identityId,
    required String networkId,
  }) async {
    final network = _networks[networkId];
    if (network == null) {
      throw Exception('Network $networkId not supported');
    }

    try {
      final reputationData = await _fetchReputationFromBlockchain(network, identityId);

      return BlockchainReputation(
        identityId: identityId,
        networkId: networkId,
        reputationScore: reputationData.score,
        totalTransactions: reputationData.totalTransactions,
        positiveInteractions: reputationData.positiveInteractions,
        negativeInteractions: reputationData.negativeInteractions,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(reputationData.lastUpdate),
        reputationFactors: reputationData.factors,
        blockchainProof: reputationData.proof,
      );
    } catch (e) {
      return BlockchainReputation(
        identityId: identityId,
        networkId: networkId,
        reputationScore: 0.0,
        totalTransactions: 0,
        positiveInteractions: 0,
        negativeInteractions: 0,
        lastUpdated: DateTime.now(),
        reputationFactors: const {},
        blockchainProof: '',
        errorMessage: e.toString(),
      );
    }
  }

  /// Создание смарт-контракта для верификации
  Future<SmartContractDeployment> deployVerificationContract({
    required String networkId,
    required Map<String, dynamic> contractConfig,
  }) async {
    final network = _networks[networkId];
    if (network == null) {
      throw Exception('Network $networkId not supported');
    }

    try {
      final deployment = await _deployContract(network, contractConfig);

      final contract = SmartContract(
        address: deployment.address,
        networkId: networkId,
        abi: deployment.abi,
        bytecode: deployment.bytecode,
        deploymentTransaction: deployment.transactionHash,
        deploymentBlock: deployment.blockNumber,
        createdAt: DateTime.now(),
        status: ContractStatus.active,
      );

      _contracts[networkId] = contract;

      return deployment;
    } catch (e) {
      return SmartContractDeployment(
        address: '',
        networkId: networkId,
        transactionHash: '',
        blockNumber: 0,
        abi: const {},
        bytecode: '',
        errorMessage: e.toString(),
      );
    }
  }

  /// Получение транзакций для идентичности
  Future<List<BlockchainTransaction>> getIdentityTransactions({
    required String identityId,
    required String networkId,
    int limit = 50,
    int offset = 0,
  }) async {
    final network = _networks[networkId];
    if (network == null) {
      throw Exception('Network $networkId not supported');
    }

    try {
      final transactions = await _fetchTransactions(network, identityId, limit, offset);

      return transactions
          .map((tx) => BlockchainTransaction(
                hash: tx.hash,
                from: tx.from,
                to: tx.to,
                value: tx.value,
                gasUsed: tx.gasUsed,
                gasPrice: tx.gasPrice,
                blockNumber: tx.blockNumber,
                timestamp: DateTime.fromMillisecondsSinceEpoch(tx.timestamp),
                status: tx.status == 'success' ? TransactionStatus.success : TransactionStatus.failed,
                data: tx.data,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Анализ активности в блокчейне
  Future<BlockchainActivityAnalysis> analyzeBlockchainActivity({
    required String identityId,
    required String networkId,
    required int days,
  }) async {
    final network = _networks[networkId];
    if (network == null) {
      throw Exception('Network $networkId not supported');
    }

    try {
      final analysisData = await _performActivityAnalysis(network, identityId, days);

      return BlockchainActivityAnalysis(
        identityId: identityId,
        networkId: networkId,
        periodDays: days,
        totalTransactions: analysisData.totalTransactions,
        uniqueCounterparties: analysisData.uniqueCounterparties,
        averageTransactionValue: analysisData.averageValue,
        activityScore: analysisData.activityScore,
        trustworthinessScore: analysisData.trustworthinessScore,
        riskFactors: analysisData.riskFactors,
        recommendations: analysisData.recommendations,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      return BlockchainActivityAnalysis(
        identityId: identityId,
        networkId: networkId,
        periodDays: days,
        totalTransactions: 0,
        uniqueCounterparties: 0,
        averageTransactionValue: 0.0,
        activityScore: 0.0,
        trustworthinessScore: 0.0,
        riskFactors: const [],
        recommendations: const [],
        generatedAt: DateTime.now(),
        errorMessage: e.toString(),
      );
    }
  }

  /// Инициализация поддерживаемых сетей
  Future<void> _initializeSupportedNetworks() async {
    // Ethereum Mainnet
    _networks['ethereum_mainnet'] = const BlockchainNetwork(
      id: 'ethereum_mainnet',
      name: 'Ethereum Mainnet',
      chainId: 1,
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_API_KEY',
      explorerUrl: 'https://etherscan.io',
      nativeCurrency: 'ETH',
      isTestnet: false,
      gasPrice: 20000000000, // 20 Gwei
    );

    // Polygon
    _networks['polygon_mainnet'] = const BlockchainNetwork(
      id: 'polygon_mainnet',
      name: 'Polygon Mainnet',
      chainId: 137,
      rpcUrl: 'https://polygon-rpc.com',
      explorerUrl: 'https://polygonscan.com',
      nativeCurrency: 'MATIC',
      isTestnet: false,
      gasPrice: 30000000000, // 30 Gwei
    );

    // Binance Smart Chain
    _networks['bsc_mainnet'] = const BlockchainNetwork(
      id: 'bsc_mainnet',
      name: 'Binance Smart Chain',
      chainId: 56,
      rpcUrl: 'https://bsc-dataseed.binance.org',
      explorerUrl: 'https://bscscan.com',
      nativeCurrency: 'BNB',
      isTestnet: false,
      gasPrice: 5000000000, // 5 Gwei
    );

    // Testnets
    _networks['ethereum_goerli'] = const BlockchainNetwork(
      id: 'ethereum_goerli',
      name: 'Ethereum Goerli Testnet',
      chainId: 5,
      rpcUrl: 'https://goerli.infura.io/v3/YOUR_API_KEY',
      explorerUrl: 'https://goerli.etherscan.io',
      nativeCurrency: 'ETH',
      isTestnet: true,
      gasPrice: 10000000000, // 10 Gwei
    );
  }

  /// Развертывание смарт-контрактов
  Future<void> _deploySmartContracts() async {
    // В реальной реализации здесь будет развертывание контрактов
    // Для демонстрации создаем заглушки
    for (final networkId in _networks.keys) {
      _contracts[networkId] = SmartContract(
        address: '0x${_generateRandomAddress()}',
        networkId: networkId,
        abi: _getVerificationContractABI(),
        bytecode: '0x${_generateRandomBytecode()}',
        deploymentTransaction: '0x${_generateRandomHash()}',
        deploymentBlock: Random().nextInt(1000000),
        createdAt: DateTime.now(),
        status: ContractStatus.active,
      );
    }
  }

  /// Настройка периодического обновления верификаций
  void _setupPeriodicVerificationUpdate() {
    Timer.periodic(const Duration(hours: 1), (timer) async {
      await _performPeriodicVerificationUpdate();
    });
  }

  /// Периодическое обновление верификаций
  Future<void> _performPeriodicVerificationUpdate() async {
    final expiredVerifications = <String>[];

    for (final entry in _verificationCache.entries) {
      if (_isVerificationExpired(entry.value)) {
        expiredVerifications.add(entry.key);
      }
    }

    // Удаляем истекшие верификации
    for (final key in expiredVerifications) {
      _verificationCache.remove(key);
    }
  }

  /// Генерация хеша идентичности
  String _generateIdentityHash(String identityId, String protocol, Map<String, dynamic> data) {
    final combinedData = '$identityId:$protocol:${jsonEncode(data)}';
    return _hashString(combinedData);
  }

  /// Регистрация в блокчейне
  Future<BlockchainTransaction> _registerOnBlockchain({
    required BlockchainNetwork network,
    required SmartContract contract,
    required String identityHash,
    required Map<String, dynamic> identityData,
    String? privateKey,
  }) async {
    // В реальной реализации здесь будет взаимодействие с блокчейном
    // Для демонстрации возвращаем заглушку
    return BlockchainTransaction(
      hash: '0x${_generateRandomHash()}',
      from: '0x${_generateRandomAddress()}',
      to: contract.address,
      value: 0,
      gasUsed: 21000,
      gasPrice: network.gasPrice,
      blockNumber: Random().nextInt(1000000),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: TransactionStatus.success,
      data: jsonEncode({
        'method': 'registerIdentity',
        'identityHash': identityHash,
        'identityData': identityData,
      }),
    );
  }

  /// Получение данных из блокчейна
  Future<Map<String, dynamic>> _fetchFromBlockchain(
    BlockchainNetwork network,
    String identityId,
  ) async {
    // В реальной реализации здесь будет запрос к блокчейну
    // Для демонстрации возвращаем заглушку
    return {
      'identityId': identityId,
      'registeredAt': DateTime.now().millisecondsSinceEpoch,
      'verificationLevel': 'basic',
      'metadata': {
        'protocol': 'matrix',
        'verified': true,
      },
    };
  }

  /// Выполнение верификации
  Future<VerificationResult> _performVerification({
    required String identityId,
    required Map<String, dynamic> blockchainData,
    required Map<String, dynamic> verificationData,
    required BlockchainNetwork network,
  }) async {
    // Анализ данных блокчейна
    final blockchainScore = _analyzeBlockchainData(blockchainData);

    // Анализ верификационных данных
    final verificationScore = _analyzeVerificationData(verificationData);

    // Общая уверенность
    final confidence = (blockchainScore + verificationScore) / 2.0;

    // Определение уровня верификации
    VerificationLevel level;
    if (confidence >= 0.9) {
      level = VerificationLevel.verified;
    } else if (confidence >= 0.7) {
      level = VerificationLevel.high;
    } else if (confidence >= 0.5) {
      level = VerificationLevel.medium;
    } else {
      level = VerificationLevel.basic;
    }

    return VerificationResult(
      level: level,
      confidence: confidence,
      proof: 'blockchain_proof_${_generateRandomHash()}',
      status: confidence >= _minConfidenceThreshold ? VerificationStatus.verified : VerificationStatus.failed,
      metadata: {
        'blockchainScore': blockchainScore,
        'verificationScore': verificationScore,
        'network': network.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Получение репутации из блокчейна
  Future<ReputationData> _fetchReputationFromBlockchain(
    BlockchainNetwork network,
    String identityId,
  ) async {
    // В реальной реализации здесь будет запрос к блокчейну
    // Для демонстрации возвращаем заглушку
    return ReputationData(
      score: Random().nextDouble(),
      totalTransactions: Random().nextInt(1000),
      positiveInteractions: Random().nextInt(500),
      negativeInteractions: Random().nextInt(50),
      lastUpdate: DateTime.now(),
      factors: {
        'transaction_frequency': Random().nextDouble(),
        'transaction_amount': Random().nextDouble(),
        'counterparty_diversity': Random().nextDouble(),
      },
      proof: 'reputation_proof_${_generateRandomHash()}',
    );
  }

  /// Развертывание контракта
  Future<SmartContractDeployment> _deployContract(
    BlockchainNetwork network,
    Map<String, dynamic> config,
  ) async {
    // В реальной реализации здесь будет развертывание контракта
    // Для демонстрации возвращаем заглушку
    return SmartContractDeployment(
      address: '0x${_generateRandomAddress()}',
      networkId: network.id,
      transactionHash: '0x${_generateRandomHash()}',
      blockNumber: Random().nextInt(1000000),
      abi: _getVerificationContractABI(),
      bytecode: '0x${_generateRandomBytecode()}',
    );
  }

  /// Получение транзакций
  Future<List<TransactionData>> _fetchTransactions(
    BlockchainNetwork network,
    String identityId,
    int limit,
    int offset,
  ) async {
    // В реальной реализации здесь будет запрос к блокчейну
    // Для демонстрации возвращаем заглушки
    final transactions = <TransactionData>[];

    for (int i = 0; i < min(limit, 10); i++) {
      transactions.add(TransactionData(
        hash: '0x${_generateRandomHash()}',
        from: '0x${_generateRandomAddress()}',
        to: '0x${_generateRandomAddress()}',
        value: Random().nextDouble() * 1000,
        gasUsed: 21000,
        gasPrice: network.gasPrice,
        blockNumber: Random().nextInt(1000000),
        timestamp: DateTime.now().subtract(Duration(days: Random().nextInt(30))).millisecondsSinceEpoch,
        status: 'success',
        data: '',
      ));
    }

    return transactions;
  }

  /// Анализ активности
  Future<ActivityAnalysisData> _performActivityAnalysis(
    BlockchainNetwork network,
    String identityId,
    int days,
  ) async {
    // В реальной реализации здесь будет анализ данных блокчейна
    // Для демонстрации возвращаем заглушку
    return ActivityAnalysisData(
      totalTransactions: Random().nextInt(1000),
      uniqueCounterparties: Random().nextInt(100),
      averageValue: Random().nextDouble() * 1000,
      activityScore: Random().nextDouble(),
      trustworthinessScore: Random().nextDouble(),
      riskFactors: const ['High transaction frequency', 'Unknown counterparties'],
      recommendations: const ['Increase verification', 'Monitor transactions'],
    );
  }

  /// Анализ данных блокчейна
  double _analyzeBlockchainData(Map<String, dynamic> data) {
    double score = 0.0;

    // Проверка регистрации
    if (data['registeredAt'] != null) score += 0.3;

    // Проверка уровня верификации
    final verificationLevel = data['verificationLevel'] as String?;
    if (verificationLevel == 'verified') {
      score += 0.4;
    } else if (verificationLevel == 'basic') score += 0.2;

    // Проверка метаданных
    final metadata = data['metadata'] as Map<String, dynamic>?;
    if (metadata?['verified'] == true) score += 0.3;

    return min(1.0, score);
  }

  /// Анализ верификационных данных
  double _analyzeVerificationData(Map<String, dynamic> data) {
    double score = 0.0;

    // Проверка наличия ключевых полей
    if (data['identityId'] != null) score += 0.2;
    if (data['protocol'] != null) score += 0.2;
    if (data['timestamp'] != null) score += 0.2;

    // Проверка подписи или других криптографических доказательств
    if (data['signature'] != null) score += 0.4;

    return min(1.0, score);
  }

  /// Проверка истечения верификации
  bool _isVerificationExpired(BlockchainVerification verification) {
    return DateTime.now().isAfter(verification.expiresAt);
  }

  /// Получение ABI контракта верификации
  Map<String, dynamic> _getVerificationContractABI() {
    return {
      'name': 'TrustVerification',
      'abi': [
        {
          'name': 'registerIdentity',
          'type': 'function',
          'inputs': [
            {'name': 'identityHash', 'type': 'bytes32'},
            {'name': 'identityData', 'type': 'string'},
          ],
          'outputs': [
            {'name': 'success', 'type': 'bool'}
          ],
        },
        {
          'name': 'verifyIdentity',
          'type': 'function',
          'inputs': [
            {'name': 'identityId', 'type': 'string'},
          ],
          'outputs': [
            {'name': 'verified', 'type': 'bool'},
            {'name': 'level', 'type': 'uint8'},
          ],
        },
      ],
    };
  }

  /// Генерация случайного хеша
  String _generateRandomHash() {
    const chars = '0123456789abcdef';
    return List.generate(64, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  /// Генерация случайного адреса
  String _generateRandomAddress() {
    const chars = '0123456789abcdef';
    return List.generate(40, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  /// Генерация случайного байткода
  String _generateRandomBytecode() {
    const chars = '0123456789abcdef';
    return List.generate(100, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  /// Хеширование строки
  String _hashString(String input) {
    // Простая реализация хеширования для демонстрации
    // В реальной реализации следует использовать криптографически стойкий хеш
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash + input.codeUnitAt(i)) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// Освобождение ресурсов
  void dispose() {
    _verificationCache.clear();
  }
}

/// Модель блокчейн сети
class BlockchainNetwork extends Equatable {
  final String id;
  final String name;
  final int chainId;
  final String rpcUrl;
  final String explorerUrl;
  final String nativeCurrency;
  final bool isTestnet;
  final int gasPrice;

  const BlockchainNetwork({
    required this.id,
    required this.name,
    required this.chainId,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.nativeCurrency,
    required this.isTestnet,
    required this.gasPrice,
  });

  @override
  List<Object?> get props => [id, name, chainId, rpcUrl, explorerUrl, nativeCurrency, isTestnet, gasPrice];
}

/// Модель смарт-контракта
class SmartContract extends Equatable {
  final String address;
  final String networkId;
  final Map<String, dynamic> abi;
  final String bytecode;
  final String deploymentTransaction;
  final int deploymentBlock;
  final DateTime createdAt;
  final ContractStatus status;

  const SmartContract({
    required this.address,
    required this.networkId,
    required this.abi,
    required this.bytecode,
    required this.deploymentTransaction,
    required this.deploymentBlock,
    required this.createdAt,
    required this.status,
  });

  @override
  List<Object?> get props =>
      [address, networkId, abi, bytecode, deploymentTransaction, deploymentBlock, createdAt, status];
}

/// Статусы контракта
enum ContractStatus {
  deploying,
  active,
  paused,
  deprecated,
}

/// Регистрация идентичности в блокчейне
class BlockchainIdentityRegistration extends Equatable {
  final String identityId;
  final String networkId;
  final String transactionHash;
  final int blockNumber;
  final DateTime timestamp;
  final RegistrationStatus status;
  final VerificationLevel verificationLevel;
  final String? errorMessage;

  const BlockchainIdentityRegistration({
    required this.identityId,
    required this.networkId,
    required this.transactionHash,
    required this.blockNumber,
    required this.timestamp,
    required this.status,
    required this.verificationLevel,
    this.errorMessage,
  });

  @override
  List<Object?> get props =>
      [identityId, networkId, transactionHash, blockNumber, timestamp, status, verificationLevel, errorMessage];
}

/// Статусы регистрации
enum RegistrationStatus {
  pending,
  confirmed,
  failed,
}

/// Уровни верификации
enum VerificationLevel {
  none,
  basic,
  medium,
  high,
  verified,
}

/// Верификация через блокчейн
class BlockchainVerification extends Equatable {
  final String identityId;
  final String networkId;
  final VerificationLevel verificationLevel;
  final double confidence;
  final String blockchainProof;
  final DateTime timestamp;
  final DateTime expiresAt;
  final VerificationStatus status;
  final Map<String, dynamic> metadata;
  final String? errorMessage;

  const BlockchainVerification({
    required this.identityId,
    required this.networkId,
    required this.verificationLevel,
    required this.confidence,
    required this.blockchainProof,
    required this.timestamp,
    required this.expiresAt,
    required this.status,
    required this.metadata,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        identityId,
        networkId,
        verificationLevel,
        confidence,
        blockchainProof,
        timestamp,
        expiresAt,
        status,
        metadata,
        errorMessage
      ];
}

/// Статусы верификации
enum VerificationStatus {
  pending,
  verified,
  failed,
  expired,
}

/// Репутация в блокчейне
class BlockchainReputation extends Equatable {
  final String identityId;
  final String networkId;
  final double reputationScore;
  final int totalTransactions;
  final int positiveInteractions;
  final int negativeInteractions;
  final DateTime lastUpdated;
  final Map<String, double> reputationFactors;
  final String blockchainProof;
  final String? errorMessage;

  const BlockchainReputation({
    required this.identityId,
    required this.networkId,
    required this.reputationScore,
    required this.totalTransactions,
    required this.positiveInteractions,
    required this.negativeInteractions,
    required this.lastUpdated,
    required this.reputationFactors,
    required this.blockchainProof,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        identityId,
        networkId,
        reputationScore,
        totalTransactions,
        positiveInteractions,
        negativeInteractions,
        lastUpdated,
        reputationFactors,
        blockchainProof,
        errorMessage
      ];
}

/// Транзакция в блокчейне
class BlockchainTransaction extends Equatable {
  final String hash;
  final String from;
  final String to;
  final double value;
  final int gasUsed;
  final int gasPrice;
  final int blockNumber;
  final DateTime timestamp;
  final TransactionStatus status;
  final String data;

  const BlockchainTransaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.gasUsed,
    required this.gasPrice,
    required this.blockNumber,
    required this.timestamp,
    required this.status,
    required this.data,
  });

  @override
  List<Object?> get props => [hash, from, to, value, gasUsed, gasPrice, blockNumber, timestamp, status, data];
}

/// Статусы транзакций
enum TransactionStatus {
  pending,
  success,
  failed,
  reverted,
}

/// Анализ активности в блокчейне
class BlockchainActivityAnalysis extends Equatable {
  final String identityId;
  final String networkId;
  final int periodDays;
  final int totalTransactions;
  final int uniqueCounterparties;
  final double averageTransactionValue;
  final double activityScore;
  final double trustworthinessScore;
  final List<String> riskFactors;
  final List<String> recommendations;
  final DateTime generatedAt;
  final String? errorMessage;

  const BlockchainActivityAnalysis({
    required this.identityId,
    required this.networkId,
    required this.periodDays,
    required this.totalTransactions,
    required this.uniqueCounterparties,
    required this.averageTransactionValue,
    required this.activityScore,
    required this.trustworthinessScore,
    required this.riskFactors,
    required this.recommendations,
    required this.generatedAt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        identityId,
        networkId,
        periodDays,
        totalTransactions,
        uniqueCounterparties,
        averageTransactionValue,
        activityScore,
        trustworthinessScore,
        riskFactors,
        recommendations,
        generatedAt,
        errorMessage
      ];
}

/// Развертывание смарт-контракта
class SmartContractDeployment extends Equatable {
  final String address;
  final String networkId;
  final String transactionHash;
  final int blockNumber;
  final Map<String, dynamic> abi;
  final String bytecode;
  final String? errorMessage;

  const SmartContractDeployment({
    required this.address,
    required this.networkId,
    required this.transactionHash,
    required this.blockNumber,
    required this.abi,
    required this.bytecode,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [address, networkId, transactionHash, blockNumber, abi, bytecode, errorMessage];
}

/// Результат верификации
class VerificationResult extends Equatable {
  final VerificationLevel level;
  final double confidence;
  final String proof;
  final VerificationStatus status;
  final Map<String, dynamic> metadata;

  const VerificationResult({
    required this.level,
    required this.confidence,
    required this.proof,
    required this.status,
    required this.metadata,
  });

  @override
  List<Object?> get props => [level, confidence, proof, status, metadata];
}

/// Данные репутации
class ReputationData extends Equatable {
  final double score;
  final int totalTransactions;
  final int positiveInteractions;
  final int negativeInteractions;
  final int lastUpdate;
  final Map<String, double> factors;
  final String proof;

  const ReputationData({
    required this.score,
    required this.totalTransactions,
    required this.positiveInteractions,
    required this.negativeInteractions,
    required this.lastUpdate,
    required this.factors,
    required this.proof,
  });

  @override
  List<Object?> get props =>
      [score, totalTransactions, positiveInteractions, negativeInteractions, lastUpdate, factors, proof];
}

/// Данные транзакции
class TransactionData extends Equatable {
  final String hash;
  final String from;
  final String to;
  final double value;
  final int gasUsed;
  final int gasPrice;
  final int blockNumber;
  final int timestamp;
  final String status;
  final String data;

  const TransactionData({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.gasUsed,
    required this.gasPrice,
    required this.blockNumber,
    required this.timestamp,
    required this.status,
    required this.data,
  });

  @override
  List<Object?> get props => [hash, from, to, value, gasUsed, gasPrice, blockNumber, timestamp, status, data];
}

/// Данные анализа активности
class ActivityAnalysisData extends Equatable {
  final int totalTransactions;
  final int uniqueCounterparties;
  final double averageValue;
  final double activityScore;
  final double trustworthinessScore;
  final List<String> riskFactors;
  final List<String> recommendations;

  const ActivityAnalysisData({
    required this.totalTransactions,
    required this.uniqueCounterparties,
    required this.averageValue,
    required this.activityScore,
    required this.trustworthinessScore,
    required this.riskFactors,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [
        totalTransactions,
        uniqueCounterparties,
        averageValue,
        activityScore,
        trustworthinessScore,
        riskFactors,
        recommendations
      ];
}
