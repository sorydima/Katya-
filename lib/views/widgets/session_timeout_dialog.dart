import 'package:flutter/material.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/l10n/l10n.dart';

class SessionTimeoutDialog extends StatelessWidget {
  final int secondsRemaining;
  final VoidCallback onExtendSession;
  final VoidCallback onLogout;

  const SessionTimeoutDialog({
    super.key,
    required this.secondsRemaining,
    required this.onExtendSession,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    return AlertDialog(
      title: Text(l10n.session_timeout_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.session_timeout_message(secondsRemaining),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: secondsRemaining / 60, // Assuming 60 seconds warning time
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onLogout,
          child: Text(
            l10n.logout,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: onExtendSession,
          child: Text(l10n.stay_signed_in),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required int secondsRemaining,
    required VoidCallback onExtendSession,
    required VoidCallback onLogout,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionTimeoutDialog(
        secondsRemaining: secondsRemaining,
        onExtendSession: onExtendSession,
        onLogout: onLogout,
      ),
    );
  }
}
