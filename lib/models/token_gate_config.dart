import 'package:equatable/equatable.dart';

/// Configuration for token-gated access control
class TokenGateConfig extends Equatable {
  /// Unique identifier for this token gate
  final String? id;

  /// The type of token gate (e.g., 'nft', 'token', 'premium')
  final String type;

  /// The contract address of the token/NFT
  final String? contract;

  /// The contract address (alias for contract for compatibility)
  String? get contractAddress => contract;

  /// The token ID (for NFTs)
  final String? tokenId;

  /// The minimum balance required (for fungible tokens)
  final String? minBalance;

  /// The token symbol (for display purposes)
  final String? symbol;

  /// The token name (for display purposes)
  final String? name;

  /// The token image URL (for display purposes)
  final String? imageUrl;

  /// The token description (for display purposes)
  final String? description;

  /// Custom message for token gate errors
  final String? customMessage;

  /// Whether this gate is enabled
  final bool isEnabled;

  /// Custom metadata for the token gate
  final Map<String, dynamic> metadata;

  const TokenGateConfig({
    this.id,
    required this.type,
    this.contract,
    this.tokenId,
    this.minBalance,
    this.symbol,
    this.name,
    this.imageUrl,
    this.description,
    this.customMessage,
    this.isEnabled = true,
    this.metadata = const {},
  });

  /// Create a TokenGateConfig from a JSON map
  factory TokenGateConfig.fromJson(Map<String, dynamic> json) {
    return TokenGateConfig(
      id: json['id'] as String?,
      type: json['type'] as String? ?? 'token',
      contract: json['contract'] as String?,
      tokenId: json['tokenId'] as String?,
      minBalance: json['minBalance'] as String?,
      symbol: json['symbol'] as String?,
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      customMessage: json['customMessage'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  /// Convert this TokenGateConfig to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      if (contract != null) 'contract': contract,
      if (tokenId != null) 'tokenId': tokenId,
      if (minBalance != null) 'minBalance': minBalance,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (description != null) 'description': description,
      if (customMessage != null) 'customMessage': customMessage,
      'isEnabled': isEnabled,
      'metadata': metadata,
    };
  }

  /// Create a copy of this TokenGateConfig with the given fields replaced
  TokenGateConfig copyWith({
    String? id,
    String? type,
    String? contract,
    String? tokenId,
    String? minBalance,
    String? symbol,
    String? name,
    String? imageUrl,
    String? description,
    String? customMessage,
    bool? isEnabled,
    Map<String, dynamic>? metadata,
  }) {
    return TokenGateConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      contract: contract ?? this.contract,
      tokenId: tokenId ?? this.tokenId,
      minBalance: minBalance ?? this.minBalance,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      customMessage: customMessage ?? this.customMessage,
      isEnabled: isEnabled ?? this.isEnabled,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        contract,
        tokenId,
        minBalance,
        symbol,
        name,
        imageUrl,
        description,
        customMessage,
        isEnabled,
        metadata,
      ];

  @override
  bool get stringify => true;
}
