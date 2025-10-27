import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/services/web3_service.dart';
import 'package:katya/store/index.dart';

class WalletConnectButton extends StatefulWidget {
  final Function? onConnected;
  final Function? onDisconnected;
  final bool showAddress;
  final bool showBalance;
  final Color? textColor;

  const WalletConnectButton({
    super.key,
    this.onConnected,
    this.onDisconnected,
    this.showAddress = true,
    this.showBalance = true,
    this.textColor,
  });

  @override
  _WalletConnectButtonState createState() => _WalletConnectButtonState();
}

class _WalletConnectButtonState extends State<WalletConnectButton> {
  final Web3Service _web3Service = Web3Service();
  bool _isConnecting = false;
  String? _balance;
  String? _truncatedAddress;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _web3Service.initialize();
    if (_web3Service.isConnected) {
      _updateWalletInfo();
      widget.onConnected?.call();
    }
  }

  Future<void> _updateWalletInfo() async {
    if (!mounted) return;

    setState(() {
      _truncatedAddress = _getTruncatedAddress(_web3Service.currentAddress!);
    });

    if (widget.showBalance) {
      try {
        final balance = await _web3Service.getBalance();
        final ethBalance = balance / BigInt.from(10).pow(18);
        setState(() {
          _balance = '${ethBalance.toStringAsFixed(4)} ETH';
        });
      } catch (e) {
        print('Error fetching balance: $e');
      }
    }
  }

  String _getTruncatedAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  Future<void> _connectWallet() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      await _web3Service.connectWallet();
      if (_web3Service.isConnected) {
        await _updateWalletInfo();
        widget.onConnected?.call();
      }
    } catch (e) {
      print('Error connecting wallet: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect wallet: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _disconnectWallet() async {
    try {
      await _web3Service.disconnectWallet();
      setState(() {
        _balance = null;
        _truncatedAddress = null;
      });
      widget.onDisconnected?.call();
    } catch (e) {
      print('Error disconnecting wallet: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to disconnect wallet: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.roomStore.loading,
      builder: (context, isLoading) {
        if (_isConnecting || isLoading) {
          return _buildLoadingButton();
        }

        if (_web3Service.isConnected) {
          return _buildConnectedButton();
        }

        return _buildConnectButton();
      },
    );
  }

  Widget _buildConnectButton() {
    return ElevatedButton.icon(
      onPressed: _connectWallet,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
        ),
      ),
      icon: Icon(
        Icons.account_balance_wallet,
        size: 20,
        color: widget.textColor,
      ),
      label: Text(
        'Connect Wallet',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: widget.textColor,
        ),
      ),
    );
  }

  Widget _buildConnectedButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'disconnect') {
          _disconnectWallet();
        } else if (value == 'copy') {
          _copyAddressToClipboard();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (widget.showAddress)
          PopupMenuItem<String>(
            value: 'copy',
            child: Row(
              children: [
                const Icon(Icons.copy, size: 20),
                const SizedBox(width: 8),
                const Text('Copy Address'),
                const Spacer(),
                Text(
                  _truncatedAddress ?? '',
                  style: TextStyle(
                    color: widget.textColor?.withOpacity(0.8) ?? Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        const PopupMenuItem<String>(
          value: 'disconnect',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Disconnect', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            if (widget.showAddress && _truncatedAddress != null) ...[
              Text(
                _truncatedAddress!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
            ],
            if (widget.showBalance && _balance != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _balance!,
                  style: TextStyle(
                    color: widget.textColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Connecting...'),
        ],
      ),
    );
  }

  void _copyAddressToClipboard() {
    if (_web3Service.currentAddress != null) {
      Clipboard.setData(ClipboardData(
        text: _web3Service.currentAddress!,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address copied to clipboard')),
      );
    }
  }
}
