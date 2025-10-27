import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../crypto/cross_signing_service.dart';
import '../../../matrix/matrix_client.dart';

class VerificationScreen extends StatefulWidget {
  final String? transactionId;
  final String? otherUserId;
  final String? otherDeviceId;
  final VerificationRequest? verificationRequest;

  const VerificationScreen({
    super.key,
    this.transactionId,
    this.otherUserId,
    this.otherDeviceId,
    this.verificationRequest,
  });

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool _isVerifying = false;
  bool _showQrCode = false;
  String? _sasEmoji;
  List<String>? _sasEmojis;
  String? _sasDecimal;

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  Future<void> _startVerification() async {
    if (widget.verificationRequest != null) {
      await _handleIncomingVerification();
    } else if (widget.otherUserId != null) {
      await _startNewVerification();
    }
  }

  Future<void> _handleIncomingVerification() async {
    final request = widget.verificationRequest;

    // Listen for SAS verification events
    request.onUpdate?.listen((update) {
      if (update is SasUpdate) {
        setState(() {
          _sasEmojis = update.emoji;
          _sasDecimal = update.decimal;
        });
      }
    });

    // Show verification method selection
    final method = await showDialog<VerificationMethod>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Verify by'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, VerificationMethod.emoji),
            child: const Text('Emoji'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, VerificationMethod.decimal),
            child: const Text('Number'),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() => _showQrCode = true);
              Navigator.pop(context, VerificationMethod.qrCode);
            },
            child: const Text('QR Code'),
          ),
        ],
      ),
    );

    if (method != null) {
      await request.accept(method);
    } else {
      await request.cancel();
      Navigator.pop(context);
    }
  }

  Future<void> _startNewVerification() async {
    final client = Provider.of<MatrixClient>(context, listen: false);
    final request = await client.startVerification(
      widget.otherUserId!,
      widget.otherDeviceId,
    );

    request.onUpdate?.listen((update) {
      if (update is SasUpdate) {
        setState(() {
          _sasEmojis = update.emoji;
          _sasDecimal = update.decimal;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Device'),
        actions: [
          if (_isVerifying)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      body: _showQrCode ? _buildQrCodeView() : _buildSasView(),
    );
  }

  Widget _buildSasView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Compare the following emojis with the other device:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_sasEmojis != null) ..._buildEmojiTiles(),
            if (_sasDecimal != null) ..._buildDecimalTiles(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isVerifying ? null : () => _verifyMatch(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Match'),
                ),
                ElevatedButton(
                  onPressed: _isVerifying ? null : () => _verifyMatch(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('No Match'),
                ),
              ],
            ),
            TextButton(
              onPressed: _isVerifying
                  ? null
                  : () {
                      setState(() => _showQrCode = true);
                    },
              child: const Text('Verify with QR Code Instead'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEmojiTiles() {
    if (_sasEmojis == null) return [];

    final emojiPairs = <Widget>[];
    for (var i = 0; i < _sasEmojis!.length; i += 2) {
      emojiPairs.add(_buildEmojiTile(_sasEmojis![i], _sasEmojis![i + 1]));
    }

    return emojiPairs;
  }

  Widget _buildEmojiTile(String emoji, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecimalTiles() {
    if (_sasDecimal == null) return [];

    return [
      const SizedBox(height: 16),
      Text(
        _sasDecimal!,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
    ];
  }

  Widget _buildQrCodeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Scan the QR code with the other device',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // TODO: Implement QR code generation
          // QrImageView(
          //   data: _qrCodeData,
          //   version: QrVersions.auto,
          //   size: 200.0,
          // ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              setState(() => _showQrCode = false);
            },
            child: const Text('Verify with Emoji Instead'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyMatch(bool isMatch) async {
    if (_isVerifying) return;

    setState(() => _isVerifying = true);

    try {
      final request = widget.verificationRequest;
      if (request != null) {
        if (isMatch) {
          await request.confirmSasMatch();
          _scaffoldKey.currentState?.showSnackBar(
            const SnackBar(content: Text('Device verified successfully!')),
          );
          Navigator.pop(context);
        } else {
          await request.mismatchSas();
          _scaffoldKey.currentState?.showSnackBar(
            const SnackBar(content: Text('Verification cancelled')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
      Navigator.pop(context);
    } finally {
      setState(() => _isVerifying = false);
    }
  }
}
