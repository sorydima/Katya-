import 'package:flutter/material.dart';
import 'package:katya/models/token_gate_config.dart';
import 'package:katya/providers/web3_provider.dart';
import 'package:katya/services/token_gate_service.dart';
import 'package:katya/theme/theme.dart';
import 'package:katya/views/widgets/buttons/primary_button.dart';
import 'package:provider/provider.dart';

class TokenGateWidget extends StatefulWidget {
  final TokenGateConfig tokenGateConfig;
  final VoidCallback? onAccessGranted;
  final bool showTitle;
  final bool showDescription;
  final bool showActionButton;
  final bool showLoading;

  const TokenGateWidget({
    super.key,
    required this.tokenGateConfig,
    this.onAccessGranted,
    this.showTitle = true,
    this.showDescription = true,
    this.showActionButton = true,
    this.showLoading = false,
  });

  @override
  _TokenGateWidgetState createState() => _TokenGateWidgetState();
}

class _TokenGateWidgetState extends State<TokenGateWidget> {
  bool _isLoading = false;
  bool _hasAccess = false;
  String? _error;

  final TokenGateService _tokenGateService = TokenGateService();

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final web3Provider = context.read<Web3Provider>();
      final currentAddress = web3Provider.ethereumAddress?.hex;

      if (currentAddress == null) {
        setState(() {
          _hasAccess = false;
          _isLoading = false;
        });
        return;
      }

      final hasAccess = await _tokenGateService.checkAccess(
        address: currentAddress,
        config: widget.tokenGateConfig,
      );

      setState(() {
        _hasAccess = hasAccess;
        _isLoading = false;
      });

      if (hasAccess && widget.onAccessGranted != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onAccessGranted!());
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to verify access. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_hasAccess) return const SizedBox.shrink();

    if (_isLoading && widget.showLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ..._buildTitle(theme),
          if (showDescription) ..._buildDescription(theme),
          if (showActionButton) ..._buildActionButtons(context, web3Provider, theme),
        ],
      ),
    );
  }

  List<Widget> _buildTitle(ThemeData theme) {
    return [
      Row(
        children: [
          Icon(Icons.lock_outline, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.tokenGateConfig.name ?? 'Restricted Access',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildDescription(ThemeData theme) {
    return [
      if (_error != null) ...[
        Text(
          _error!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
      ],
      Text(
        widget.tokenGateConfig.description ?? 'This content is only available to token holders.',
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
    ];
  }

  Future<void> _connectWallet(Web3Provider web3Provider) async {
    try {
      await web3Provider.connect();
      await _checkAccess();
    } catch (e) {
      setState(() {
        _error = 'Failed to connect wallet. Please try again.';
      });
    }
  }

  Future<void> _handleAccessRequest(BuildContext context, Web3Provider web3Provider) async {
    if (!web3Provider.isConnected) {
      await _connectWallet(web3Provider);
      return;
    }

    // Re-check access when user manually requests
    await _checkAccess();

    if (!_hasAccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have the required tokens to access this content'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getActionButtonText() {
    if (_isLoading) return 'Checking...';
    if (_error != null) return 'Try Again';
    return 'Verify Access';
  }

  List<Widget> _buildActionButtons(BuildContext context, Web3Provider web3Provider, ThemeData theme) {
    return [
      if (!web3Provider.isConnected)
        PrimaryButton(
          onPressed: () => _connectWallet(web3Provider),
          child: const Text('Connect Wallet'),
        )
      else
        Row(
          children: [
            Expanded(
              child: PrimaryButton.outlined(
                onPressed: () => _handleAccessRequest(context, web3Provider),
                child: Text(_getActionButtonText()),
              ),
            ),
          ],
        ),
    ];
  }

  String _getTitle() {
    final type = tokenGateConfig['type'] ?? 'premium';
    switch (type) {
      case 'nft':
        return 'NFT Holder Access';
      case 'token':
        return 'Token Holder Access';
      case 'premium':
      default:
        return 'Premium Content';
    }
  }

  String _getDescription() {
    final type = tokenGateConfig['type'] ?? 'premium';

    if (tokenGateConfig['description'] != null) {
      return tokenGateConfig['description'];
    }

    switch (type) {
      case 'nft':
        return 'This content is only available to holders of specific NFTs. '
            'Connect your wallet to verify your access.';
      case 'token':
        final amount = tokenGateConfig['amount'] ?? 'some';
        final symbol = tokenGateConfig['symbol'] ?? 'tokens';
        return 'This content requires holding $amount $symbol to access. '
            'Connect your wallet to verify your balance.';
      case 'premium':
      default:
        return 'This is premium content that requires a subscription. '
            'Upgrade your account to access exclusive features.';
    }
  }

  String _getActionButtonText() {
    final type = tokenGateConfig['type'] ?? 'premium';
    switch (type) {
      case 'nft':
        return 'View Collection';
      case 'token':
        return 'Get Tokens';
      case 'premium':
      default:
        return 'Upgrade to Premium';
    }
  }

  Future<void> _connectWallet(Web3Provider web3Provider) async {
    try {
      await web3Provider.connect();
      // Check access again after connecting
      if (onAccessGranted != null && await _checkAccess(web3Provider.ethereumAddress?.hex ?? '', tokenGateConfig)) {
        onAccessGranted!();
      }
    } catch (e) {
      // Handle connection error
      debugPrint('Error connecting wallet: $e');
    }
  }

  Future<void> _handleAccessRequest(BuildContext context, Web3Provider web3Provider) async {
    final type = tokenGateConfig['type'] ?? 'premium';

    switch (type) {
      case 'nft':
        _openNftCollection();
      case 'token':
        _openTokenPurchase();
      case 'premium':
      default:
        _openPremiumUpgrade(context);
    }
  }

  void _openNftCollection() {
    final contract = tokenGateConfig['contract'];
    // Implement NFT collection view
    debugPrint('Opening NFT collection: $contract');
  }

  void _openTokenPurchase() {
    final tokenAddress = tokenGateConfig['token'];
    // Implement token purchase flow
    debugPrint('Opening token purchase for: $tokenAddress');
  }

  void _openPremiumUpgrade(BuildContext context) {
    // Navigate to premium subscription screen
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => const PremiumScreen(),
    // ));
  }

  bool _checkAccess(String address, Map<String, dynamic> config) {
    // Implement actual access check logic here
    // This is a simplified example
    return false;
  }
}

class TokenGateAccess extends StatelessWidget {
  final String? address;
  final TokenGateConfig config;
  final Widget child;
  final Widget? loadingWidget;
  final Widget? deniedWidget;

  const TokenGateAccess({
    super.key,
    required this.address,
    required this.config,
    required this.child,
    this.loadingWidget,
    this.deniedWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (!config.isEnabled) {
      return child;
    }

    return FutureBuilder<bool>(
      future: _checkAccess(context, address, config),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        return deniedWidget ??
            TokenGateWidget(
              tokenGateConfig: config,
              showLoading: false,
            );
      },
    );
  }

  bool _checkAccess(String address, Map<String, dynamic> config) {
    // Implement actual access check logic here
    // This is a simplified example
    return false;
  }
}
