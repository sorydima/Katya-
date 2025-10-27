import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:provider/provider.dart';

import '../../../matrix/matrix_client.dart';
import '../../verification/screens/verification_screen.dart';

/// A dialog that shows up when a verification request is received
class VerificationRequestDialog extends StatefulWidget {
  final matrix.VerificationRequest request;

  const VerificationRequestDialog({
    super.key,
    required this.request,
  });

  @override
  _VerificationRequestDialogState createState() => _VerificationRequestDialogState();
}

class _VerificationRequestDialogState extends State<VerificationRequestDialog> {
  bool _isResponding = false;

  @override
  void initState() {
    super.initState();
    // Automatically close the dialog if the request is cancelled or completed
    widget.request.onUpdate.listen((update) {
      if (update is matrix.VerificationDone || update is matrix.VerificationCancelled) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verification Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.request.otherUser} wants to verify your device.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'This will verify that you are the owner of this device.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isResponding ? null : () => _respondToRequest(accept: false),
          child: const Text('Deny'),
        ),
        TextButton(
          onPressed: _isResponding ? null : () => _respondToRequest(accept: true),
          child: const Text('Accept'),
        ),
      ],
    );
  }

  Future<void> _respondToRequest({required bool accept}) async {
    if (_isResponding) return;

    setState(() => _isResponding = true);

    try {
      if (accept) {
        // Navigate to verification screen
        if (!mounted) return;

        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              verificationRequest: widget.request,
            ),
          ),
        );

        if (result == true) {
          // Verification was successful
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Device verified successfully!')),
            );
          }
        }
      } else {
        // Reject the request
        await widget.request.cancel(
          code: matrix.VerificationCancelCode.user,
          reason: 'User declined',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResponding = false);
      }
    }
  }
}

/// A widget that listens for verification requests and shows a dialog when one is received
class VerificationRequestListener extends StatefulWidget {
  final Widget child;

  const VerificationRequestListener({
    super.key,
    required this.child,
  });

  @override
  _VerificationRequestListenerState createState() => _VerificationRequestListenerState();
}

class _VerificationRequestListenerState extends State<VerificationRequestListener> {
  StreamSubscription<matrix.VerificationRequest>? _subscription;
  matrix.VerificationRequest? _currentRequest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToVerificationRequests();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToVerificationRequests() {
    final client = Provider.of<MatrixClient>(context, listen: false);
    _subscription = client.onVerificationRequest.listen(_handleVerificationRequest);
  }

  void _handleVerificationRequest(matrix.VerificationRequest request) {
    // Don't show the dialog if there's already one showing
    if (_currentRequest != null) return;

    _currentRequest = request;

    // Show the verification dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VerificationRequestDialog(request: request),
    ).then((_) {
      _currentRequest = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
