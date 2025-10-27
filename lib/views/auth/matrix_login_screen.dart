import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/matrix_provider.dart';

class MatrixLoginScreen extends StatefulWidget {
  const MatrixLoginScreen({super.key});

  @override
  _MatrixLoginScreenState createState() => _MatrixLoginScreenState();
}

class _MatrixLoginScreenState extends State<MatrixLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeserverController = TextEditingController(
    text: 'https://matrix.org', // Default homeserver
  );
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _homeserverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final matrixProvider = Provider.of<MatrixProvider>(context, listen: false);

      // First, initialize the client if needed
      if (!matrixProvider.isInitialized) {
        await matrixProvider.initialize();
      }

      // Then, attempt to login
      await matrixProvider.login(
        homeserver: _homeserverController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // If successful, navigate to the chat screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/chat');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix Login'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or header
                const SizedBox(height: 32),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign in to Matrix',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Error message
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Homeserver field
                TextFormField(
                  controller: _homeserverController,
                  decoration: const InputDecoration(
                    labelText: 'Homeserver',
                    prefixIcon: Icon(Icons.dns_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a homeserver URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                    hintText: '@username:example.com',
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 16),

                // Register link
                TextButton(
                  onPressed: () {
                    // TODO: Implement registration flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration not implemented yet')),
                    );
                  },
                  child: const Text('Create an account'),
                ),

                // Forgot password link
                TextButton(
                  onPressed: () {
                    // TODO: Implement password reset flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset not implemented yet')),
                    );
                  },
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
