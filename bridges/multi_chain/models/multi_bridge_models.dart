import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'multi_bridge_models.g.dart';

enum BridgeType {
  trusted,
  atomic,
  liquidity,
  wrapped,
}

enum BlockchainType {
  evm,
  substrate,
  solana,
  bitcoin,
  cosmos,
  avalanche,
  rechain,
  cardano,
  polygon,
  bsc,
  base,
  stellar,
  tezos,
  algorand,
  flow,
  hedera,
  // Advanced blockchain types
  polkadot_parachain,
  cosmos_zone,
  avalanche_subnet,
  ethereum_l2,
  bitcoin_sidechain,
  interoperability_protocol,
}

enum TransactionStatus {
  pending,
  confirmed,
  failed,
  cancelled,
}

enum AlertType {
  bridgeDown,
  highFees,
  liquidityLow,
  securityIssue,
  maintenance,
}

enum AlertSeverity {
  info,
  warning,
  error,
  critical,
}

enum ContractType {
  erc20,
  erc721,
  erc1155,
  substrate,
  solanaProgram,
  cosmosModule,
}

enum PositionType {
  liquidity,
  staking,
  farming,
  lending,
  borrowing,
}

enum EventType {
  transactionStarted,
  transactionCompleted,
  transactionFailed,
  bridgeMaintenance,
  liquidityChanged,
  feeUpdated,
}

enum BridgeStatus {
  online,
  offline,
  degraded,
  maintenance,
}

enum AIStatus {
  online,
  offline,
  rateLimited,
  maintenance,
}

enum SystemHealth {
  healthy,
  degraded,
  unhealthy,
}

@JsonSerializable()
class BlockchainConnector extends Equatable {
  final String id;
  final String name;
  final String rpcUrl;
  final BlockchainType type;
  final BridgeStatus status;
  final DateTime lastConnected;
  final Map<String, dynamic> config;

  const BlockchainConnector({
    required this.id,
    required this.name,
    required this.rpcUrl,
    required this.type,
    this.status = BridgeStatus.offline,
    required this.lastConnected,
    this.config = const {},
  });

  factory BlockchainConnector.fromJson(Map<String, dynamic> json) => _$BlockchainConnectorFromJson(json);
  Map<String, dynamic> toJson() => _$BlockchainConnectorToJson(this);

  @override
  List<Object?> get props => [id, name, rpcUrl, type, status, lastConnected, config];
}

@JsonSerializable()
class BridgeConfiguration extends Equatable {
  final String name;
  final BlockchainType type;
  final bool supportsNFT;
  final bool supportsDeFi;
  final Duration maxBlockTime;
  final int confirmationBlocks;
  final Map<String, dynamic> features;

  const BridgeConfiguration({
    required this.name,
    required this.type,
    this.supportsNFT = false,
    this.supportsDeFi = false,
    required this.maxBlockTime,
    required this.confirmationBlocks,
    this.features = const {},
  });

  factory BridgeConfiguration.fromJson(Map<String, dynamic> json) => _$BridgeConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$BridgeConfigurationToJson(this);

  @override
  List<Object?> get props => [name, type, supportsNFT, supportsDeFi, maxBlockTime, confirmationBlocks, features];
}

@JsonSerializable()
class CrossChainBridge extends Equatable {
  final String id;
  final String fromChain;
  final String toChain;
  final BridgeType bridgeType;
  final double fee;
  final Duration estimatedTime;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const CrossChainBridge({
    required this.id,
    required this.fromChain,
    required this.toChain,
    required this.bridgeType,
    this.fee = 0.0,
    required this.estimatedTime,
    this.isActive = true,
    this.metadata = const {},
  });

  factory CrossChainBridge.fromJson(Map<String, dynamic> json) => _$CrossChainBridgeFromJson(json);
  Map<String, dynamic> toJson() => _$CrossChainBridgeToJson(this);

  @override
  List<Object?> get props => [id, fromChain, toChain, bridgeType, fee, estimatedTime, isActive, metadata];
}

@JsonSerializable()
class CrossChainResult extends Equatable {
  final bool success;
  final String? transactionId;
  final String? fromHash;
  final String? toHash;
  final double? fee;
  final Duration? duration;
  final String? error;
  final Map<String, dynamic>? metadata;

  const CrossChainResult({
    required this.success,
    this.transactionId,
    this.fromHash,
    this.toHash,
    this.fee,
    this.duration,
    this.error,
    this.metadata,
  });

  const CrossChainResult.success({
    this.transactionId,
    this.fromHash,
    this.toHash,
    this.fee,
    this.duration,
    this.metadata,
  }) : success = true, error = null;

  const CrossChainResult.failure({this.error}) : success = false, transactionId = null, fromHash = null, toHash = null, fee = null, duration = null, metadata = null;

  factory CrossChainResult.fromJson(Map<String, dynamic> json) => _$CrossChainResultFromJson(json);
  Map<String, dynamic> toJson() => _$CrossChainResultToJson(this);

  @override
  List<Object?> get props => [success, transactionId, fromHash, toHash, fee, duration, error, metadata];
}

@JsonSerializable()
class BridgeFees extends Equatable {
  final double bridgeFee;
  final double networkFee;
  final double liquidityFee;
  final double totalFee;
  final String feeToken;
  final DateTime validUntil;

  const BridgeFees({
    this.bridgeFee = 0.0,
    this.networkFee = 0.0,
    this.liquidityFee = 0.0,
    this.totalFee = 0.0,
    required this.feeToken,
    required this.validUntil,
  });

  factory BridgeFees.fromJson(Map<String, dynamic> json) => _$BridgeFeesFromJson(json);
  Map<String, dynamic> toJson() => _$BridgeFeesToJson(this);

  @override
  List<Object?> get props => [bridgeFee, networkFee, liquidityFee, totalFee, feeToken, validUntil];
}

@JsonSerializable()
class BlockchainTransaction extends Equatable {
  final String transactionId;
  final String blockchainId;
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String tokenAddress;
  final TransactionStatus status;
  final DateTime timestamp;
  final double gasUsed;
  final String gasPrice;
  final Map<String, dynamic> metadata;

  const BlockchainTransaction({
    required this.transactionId,
    required this.blockchainId,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.tokenAddress,
    this.status = TransactionStatus.pending,
    required this.timestamp,
    this.gasUsed = 0.0,
    this.gasPrice = '0',
    this.metadata = const {},
  });

  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) => _$BlockchainTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$BlockchainTransactionToJson(this);

  @override
  List<Object?> get props => [transactionId, blockchainId, fromAddress, toAddress, amount, tokenAddress, status, timestamp, gasUsed, gasPrice, metadata];
}

@JsonSerializable()
class BridgeLiquidity extends Equatable {
  final String bridgeId;
  final String tokenAddress;
  final String totalLiquidity;
  final String availableLiquidity;
  final double utilizationRate;
  final double apy;
  final DateTime lastUpdated;

  const BridgeLiquidity({
    required this.bridgeId,
    required this.tokenAddress,
    required this.totalLiquidity,
    required this.availableLiquidity,
    this.utilizationRate = 0.0,
    this.apy = 0.0,
    required this.lastUpdated,
  });

  factory BridgeLiquidity.fromJson(Map<String, dynamic> json) => _$BridgeLiquidityFromJson(json);
  Map<String, dynamic> toJson() => _$BridgeLiquidityToJson(this);

  @override
  List<Object?> get props => [bridgeId, tokenAddress, totalLiquidity, availableLiquidity, utilizationRate, apy, lastUpdated];
}

@JsonSerializable()
class BridgeMetrics extends Equatable {
  final String bridgeId;
  final int totalTransactions;
  final double totalVolume;
  final double averageFee;
  final Duration averageTime;
  final double successRate;
  final DateTime periodStart;
  final DateTime periodEnd;

  const BridgeMetrics({
    required this.bridgeId,
    this.totalTransactions = 0,
    this.totalVolume = 0.0,
    this.averageFee = 0.0,
    this.averageTime = Duration.zero,
    this.successRate = 0.0,
    required this.periodStart,
    required this.periodEnd,
  });

  factory BridgeMetrics.fromJson(Map<String, dynamic> json) => _$BridgeMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$BridgeMetricsToJson(this);

  @override
  List<Object?> get props => [bridgeId, totalTransactions, totalVolume, averageFee, averageTime, successRate, periodStart, periodEnd];
}

@JsonSerializable()
class WalletBalance extends Equatable {
  final String address;
  final String blockchainId;
  final String tokenAddress;
  final String balance;
  final String symbol;
  final int decimals;
  final double usdValue;

  const WalletBalance({
    required this.address,
    required this.blockchainId,
    required this.tokenAddress,
    required this.balance,
    required this.symbol,
    this.decimals = 18,
    this.usdValue = 0.0,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) => _$WalletBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$WalletBalanceToJson(this);

  @override
  List<Object?> get props => [address, blockchainId, tokenAddress, balance, symbol, decimals, usdValue];
}

@JsonSerializable()
class BridgeAlert extends Equatable {
  final String alertId;
  final String bridgeId;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const BridgeAlert({
    required this.alertId,
    required this.bridgeId,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    this.data = const {},
  });

  factory BridgeAlert.fromJson(Map<String, dynamic> json) => _$BridgeAlertFromJson(json);
  Map<String, dynamic> toJson() => _$BridgeAlertToJson(this);

  @override
  List<Object?> get props => [alertId, bridgeId, type, severity, title, description, timestamp, data];
}

@JsonSerializable()
class BridgeSystemStatus extends Equatable {
  final Map<String, BridgeStatus> blockchainStatus;
  final Map<String, AIStatus> aiStatus;
  final DateTime lastUpdated;
  final SystemHealth health;

  const BridgeSystemStatus({
    this.blockchainStatus = const {},
    this.aiStatus = const {},
    required this.lastUpdated,
    this.health = SystemHealth.healthy,
  });

  factory BridgeSystemStatus.fromJson(Map<String, dynamic> json) => _$BridgeSystemStatusFromJson(json);
  Map<String, dynamic> toJson() => _$BridgeSystemStatusToJson(this);

  @override
  List<Object?> get props => [blockchainStatus, aiStatus, lastUpdated, health];
}

@JsonSerializable()
class SmartContract extends Equatable {
  final String contractAddress;
  final String blockchainId;
  final String name;
  final String abi;
  final ContractType type;
  final DateTime deployedAt;
  final String creator;
  final Map<String, dynamic> metadata;

  const SmartContract({
    required this.contractAddress,
    required this.blockchainId,
    required this.name,
    required this.abi,
    required this.type,
    required this.deployedAt,
    required this.creator,
    this.metadata = const {},
  });

  factory SmartContract.fromJson(Map<String, dynamic> json) => _$SmartContractFromJson(json);
  Map<String, dynamic> toJson() => _$SmartContractToJson(this);

  @override
  List<Object?> get props => [contractAddress, blockchainId, name, abi, type, deployedAt, creator, metadata];
}

@JsonSerializable()
class NFTAsset extends Equatable {
  final String tokenId;
  final String contractAddress;
  final String blockchainId;
  final String owner;
  final String name;
  final String description;
  final String imageUrl;
  final Map<String, dynamic> attributes;
  final double? floorPrice;

  const NFTAsset({
    required this.tokenId,
    required this.contractAddress,
    required this.blockchainId,
    required this.owner,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.attributes = const {},
    this.floorPrice,
  });

  factory NFTAsset.fromJson(Map<String, dynamic> json) => _$NFTAssetFromJson(json);
  Map<String, dynamic> toJson() => _$NFTAssetToJson(this);

  @override
  List<Object?> get props => [tokenId, contractAddress, blockchainId, owner, name, description, imageUrl, attributes, floorPrice];
}

@JsonSerializable()
class DeFiPosition extends Equatable {
  final String positionId;
  final String protocol;
  final String blockchainId;
  final String userAddress;
  final PositionType type;
  final String assetA;
  final String assetB;
  final String amountA;
  final String amountB;
  final double apy;
  final double impermanentLoss;
  final DateTime createdAt;

  const DeFiPosition({
    required this.positionId,
    required this.protocol,
    required this.blockchainId,
    required this.userAddress,
    required this.type,
    required this.assetA,
    required this.assetB,
    required this.amountA,
    required this.amountB,
    this.apy = 0.0,
    this.impermanentLoss = 0.0,
    required this.createdAt,
  });

  factory DeFiPosition.fromJson(Map<String, dynamic> json) => _$DeFiPositionFromJson(json);
  Map<String, dynamic> toJson() => _$DeFiPositionToJson(this);

  @override
  List<Object?> get props => [positionId, protocol, blockchainId, userAddress, type, assetA, assetB, amountA, amountB, apy, impermanentLoss, createdAt];
}

@JsonSerializable()
class BridgeEvent extends Equatable {
  final String eventId;
  final String bridgeId;
  final EventType type;
  final String transactionId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool success;

  const BridgeEvent({
    required this.eventId,
    required this.bridgeId,
    required this.type,
    required this.transactionId,
    this.data = const {},
    required this.timestamp,
    this.success = true,
  });

  factory BridgeEvent.fromJson(Map<String, dynamic> json) => _$BridgeEventFromJson(json);
  Map<String, dynamic> toJson() => _$BridgeEventToJson(this);

  @override
  List<Object?> get props => [eventId, bridgeId, type, transactionId, data, timestamp, success];
}

@JsonSerializable()
class BridgeConfig extends Equatable {
  final String configId;
  final String bridgeId;
  final Map<String, dynamic> parameters;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BridgeConfig({
    required this.configId,
    required this.bridgeId,
    this.parameters = const {},
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory BridgeConfig.fromJson(Map<String, dynamic> json) => _$BridgeConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BridgeConfigToJson(this);

  @override
  List<Object?> get props => [configId, bridgeId, parameters, isActive, createdAt, updatedAt];
}

@JsonSerializable()
class PolkadotConnector extends BlockchainConnector {
  const PolkadotConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'polkadot',
    name: 'Polkadot',
    type: BlockchainType.substrate,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    // Implementation for Polkadot connection test
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class EthereumConnector extends BlockchainConnector {
  const EthereumConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'ethereum',
    name: 'Ethereum',
    type: BlockchainType.evm,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    // Implementation for Ethereum connection test
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class SolanaConnector extends BlockchainConnector {
  const SolanaConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'solana',
    name: 'Solana',
    type: BlockchainType.solana,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    // Implementation for Solana connection test
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class BitcoinConnector extends BlockchainConnector {
  const BitcoinConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'bitcoin',
    name: 'Bitcoin',
    type: BlockchainType.bitcoin,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    // Implementation for Bitcoin connection test
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class CosmosConnector extends BlockchainConnector {
  const CosmosConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'cosmos',
    name: 'Cosmos Hub',
    type: BlockchainType.cosmos,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    // Implementation for Cosmos connection test
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class REChainConnector extends BlockchainConnector {
  const REChainConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'rechain',
    name: 'REChain',
    type: BlockchainType.rechain,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    // Implementation for REChain connection test
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class CardanoConnector extends BlockchainConnector {
  const CardanoConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'cardano',
    name: 'Cardano',
    type: BlockchainType.cardano,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    // Implementation for Cardano connection test
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class PolygonConnector extends BlockchainConnector {
  const PolygonConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'polygon',
    name: 'Polygon',
    type: BlockchainType.evm,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class BSCConnector extends BlockchainConnector {
  const BSCConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'bsc',
    name: 'Binance Smart Chain',
    type: BlockchainType.evm,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class BaseConnector extends BlockchainConnector {
  const BaseConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'base',
    name: 'Base',
    type: BlockchainType.evm,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class StellarConnector extends BlockchainConnector {
  const StellarConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'stellar',
    name: 'Stellar',
    type: BlockchainType.stellar,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class TezosConnector extends BlockchainConnector {
  const TezosConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'tezos',
    name: 'Tezos',
    type: BlockchainType.tezos,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class AlgorandConnector extends BlockchainConnector {
  const AlgorandConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'algorand',
    name: 'Algorand',
    type: BlockchainType.algorand,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class FlowConnector extends BlockchainConnector {
  const FlowConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'flow',
    name: 'Flow',
    type: BlockchainType.flow,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class HederaConnector extends BlockchainConnector {
  const HederaConnector({
    required super.rpcUrl,
    super.privateKey,
    super.config,
  }) : super(
    id: 'hedera',
    name: 'Hedera',
    type: BlockchainType.hedera,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

// Advanced Blockchain Connectors

@JsonSerializable()
class PolkadotParachainConnector extends BlockchainConnector {
  final String parachainId;
  final String relayChainRpc;

  const PolkadotParachainConnector({
    required super.rpcUrl,
    required this.parachainId,
    required this.relayChainRpc,
    super.privateKey,
    super.config,
  }) : super(
    id: 'polkadot_parachain_$parachainId',
    name: 'Polkadot Parachain $parachainId',
    type: BlockchainType.polkadot_parachain,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class CosmosZoneConnector extends BlockchainConnector {
  final String zoneId;
  final String hubRpc;

  const CosmosZoneConnector({
    required super.rpcUrl,
    required this.zoneId,
    required this.hubRpc,
    super.privateKey,
    super.config,
  }) : super(
    id: 'cosmos_zone_$zoneId',
    name: 'Cosmos Zone $zoneId',
    type: BlockchainType.cosmos_zone,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class AvalancheSubnetConnector extends BlockchainConnector {
  final String subnetId;
  final String primaryNetworkRpc;

  const AvalancheSubnetConnector({
    required super.rpcUrl,
    required this.subnetId,
    required this.primaryNetworkRpc,
    super.privateKey,
    super.config,
  }) : super(
    id: 'avalanche_subnet_$subnetId',
    name: 'Avalanche Subnet $subnetId',
    type: BlockchainType.avalanche_subnet,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class EthereumL2Connector extends BlockchainConnector {
  final String l2Type; // optimism, arbitrum, zkSync, etc.
  final String l1Rpc;

  const EthereumL2Connector({
    required super.rpcUrl,
    required this.l2Type,
    required this.l1Rpc,
    super.privateKey,
    super.config,
  }) : super(
    id: 'ethereum_l2_$l2Type',
    name: 'Ethereum L2 ($l2Type)',
    type: BlockchainType.ethereum_l2,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class BitcoinSidechainConnector extends BlockchainConnector {
  final String sidechainType; // liquid, elements, etc.
  final String mainchainRpc;

  const BitcoinSidechainConnector({
    required super.rpcUrl,
    required this.sidechainType,
    required this.mainchainRpc,
    super.privateKey,
    super.config,
  }) : super(
    id: 'bitcoin_sidechain_$sidechainType',
    name: 'Bitcoin Sidechain ($sidechainType)',
    type: BlockchainType.bitcoin_sidechain,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}

@JsonSerializable()
class InteroperabilityProtocolConnector extends BlockchainConnector {
  final String protocolType; // polkadot_xcm, cosmos_ibc, etc.

  const InteroperabilityProtocolConnector({
    required super.rpcUrl,
    required this.protocolType,
    super.privateKey,
    super.config,
  }) : super(
    id: 'interoperability_$protocolType',
    name: 'Interoperability Protocol ($protocolType)',
    type: BlockchainType.interoperability_protocol,
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<BridgeStatus> getStatus() async {
    return BridgeStatus.online;
  }
}
