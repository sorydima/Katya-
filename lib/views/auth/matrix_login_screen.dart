import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../providers/matrix_provider.dart';
import '../main_app_screen.dart';

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

      // If successful, navigate to the main app
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e, st) {
      // Log the underlying error for debugging while showing a friendly message to the user
      // ignore: avoid_print
      print('Matrix login error: $e\n$st');
      setState(() {
        _error = 'auth.loginError'.tr();
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
        title: Text('navigation.login'.tr()),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 600 ? 420.0 : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'auth.login'.tr(),
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

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

                        TextFormField(
                          controller: _homeserverController,
                          decoration: InputDecoration(
                            labelText: 'protocols.matrix'.tr(),
                            prefixIcon: const Icon(Icons.dns_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'validation.url'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'auth.email'.tr(),
                            prefixIcon: const Icon(Icons.person_outline),
                            border: const OutlineInputBorder(),
                            hintText: '@user:matrix.org',
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'validation.required'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'auth.password'.tr(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'auth.passwordRequired'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

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
                              : Text('auth.login'.tr()),
                        ),
                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('auth.registerError'.tr())),
                            );
                          },
                          child: Text('navigation.register'.tr()),
                        ),

                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('errors.unknownError'.tr())),
                            );
                          },
                          child: Text('auth.forgotPassword'.tr()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
