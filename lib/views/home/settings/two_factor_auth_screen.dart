import 'package:flutter/material.dart';
import 'package:katya/views/widgets/appbars/appbar-normal.dart';
import 'package:katya/views/widgets/containers/card-section.dart';
import 'package:katya/views/widgets/dialogs/dialog-rounded.dart';

class TwoFactorAuthScreen extends StatelessWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarNormal(
        title: 'Two-Factor Authentication',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            CardSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add 2FA Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAuthMethodTile(
                    context,
                    icon: Icons.smartphone,
                    title: 'Authenticator App',
                    subtitle: 'Use an app like Google Authenticator or Authy',
                    onTap: () => _showAuthenticatorSetup(context),
                  ),
                  const Divider(),
                  _buildAuthMethodTile(
                    context,
                    icon: Icons.sms,
                    title: 'SMS Authentication',
                    subtitle: 'Receive verification codes via SMS',
                    onTap: () => _showSmsSetup(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CardSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recovery Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Recovery Email'),
                    subtitle: const Text('Add or change your recovery email'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showRecoveryEmailDialog(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Recovery Codes'),
                    subtitle: const Text('Generate new recovery codes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showRecoveryCodesDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthMethodTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAuthenticatorSetup(BuildContext context) {
    // TODO: Implement authenticator setup flow
    showDialog(
      context: context,
      builder: (context) => DialogRounded(
        title: 'Set Up Authenticator App',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            const Text('Scan the QR code with your authenticator app or enter this code manually:'),
            const SizedBox(height: 16),
            const Text(
              'JBSWY3DPEHPK3PXP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Enter the verification code from your app:'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Verify the code
                Navigator.pop(context);
                _showSuccessDialog(context, 'Authenticator app set up successfully!');
              },
              child: const Text('Verify and Activate'),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSmsSetup(BuildContext context) {
    // TODO: Implement SMS setup flow
    showDialog(
      context: context,
      builder: (context) => DialogRounded(
        title: 'Set Up SMS Authentication',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            const Text('Enter your phone number to receive verification codes:'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 (555) 123-4567',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Send verification code
                Navigator.pop(context);
                _showVerificationCodeDialog(context);
              },
              child: const Text('Send Verification Code'),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVerificationCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DialogRounded(
        title: 'Enter Verification Code',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            const Text('Enter the 6-digit code sent to your phone:'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Verify the code
                Navigator.pop(context);
                _showSuccessDialog(context, 'SMS authentication set up successfully!');
              },
              child: const Text('Verify and Activate'),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRecoveryEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DialogRounded(
        title: 'Set Recovery Email',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            const Text('Enter your recovery email address:'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Save recovery email
                Navigator.pop(context);
                _showSuccessDialog(context, 'Recovery email updated successfully!');
              },
              child: const Text('Save Email'),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRecoveryCodesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DialogRounded(
        title: 'Recovery Codes',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            const Text(
              'Save these recovery codes in a safe place. You can use them to access your account if you lose access to your 2FA device.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${_generateRandomCode()}-${_generateRandomCode()}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Copy codes to clipboard
                    Navigator.pop(context);
                  },
                  child: const Text('Copy Codes'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Print codes
                    Navigator.pop(context);
                  },
                  child: const Text('Print Codes'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Download as PDF
                    Navigator.pop(context);
                  },
                  child: const Text('Download PDF'),
                ),
              ],
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _generateRandomCode() {
    return List.generate(4, (_) => (0 + (DateTime.now().millisecondsSinceEpoch * 1000) % 10).toString()).join('');
  }
}
