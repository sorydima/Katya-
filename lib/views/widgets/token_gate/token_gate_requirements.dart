import 'package:flutter/material.dart';
import 'package:katya/models/token_gate_config.dart';
import 'package:katya/models/token_gate_type.dart';

class TokenGateRequirements extends StatelessWidget {
  final TokenGateConfig? config;
  final VoidCallback? onConnectWallet;
  final bool isLoading;
  final String? error;

  const TokenGateRequirements({
    super.key,
    this.config,
    this.onConnectWallet,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (config == null || !config!.isEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Restricted Access',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirementText(context),
          if (error != null) ..._buildErrorSection(context),
          if (onConnectWallet != null) ..._buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildRequirementText(BuildContext context) {
    String requirementText = '';

    switch (config?.type) {
      case TokenGateType.nft:
        requirementText = 'This room requires a specific NFT to join. ';
        if (config?.nftContractAddress != null) {
          requirementText += 'Contract: ${config!.nftContractAddress} ';
          if (config?.nftTokenId != null) {
            requirementText += '(Token ID: ${config!.nftTokenId})';
          }
        }
      case TokenGateType.token:
        requirementText = 'This room requires a minimum token balance to join. ';
        if (config?.tokenAddress != null) {
          requirementText += 'Token: ${config!.tokenAddress} ';
          if (config?.minTokenBalance != null) {
            requirementText += '(Min: ${config!.minTokenBalance})';
          }
        }
      case TokenGateType.premium:
        requirementText = 'This is a premium room. ';
      default:
        requirementText = 'This room has restricted access. ';
    }

    if (config?.customMessage?.isNotEmpty == true) {
      requirementText += '\n\n${config!.customMessage}';
    }

    return Text(
      requirementText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
    );
  }

  List<Widget> _buildErrorSection(BuildContext context) {
    return [
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error ?? 'An unknown error occurred',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    return [
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onConnectWallet,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            foregroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.onPrimary,
            ),
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 16),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Connect Wallet'),
        ),
      ),
    ];
  }
}
