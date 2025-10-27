import 'package:flutter/material.dart';
import 'package:katya/models/token_gate_config.dart';

class TokenGateEditor extends StatefulWidget {
  final TokenGateConfig? initialConfig;
  final Function(TokenGateConfig)? onSave;
  final Function()? onCancel;

  const TokenGateEditor({
    super.key,
    this.initialConfig,
    this.onSave,
    this.onCancel,
  });

  @override
  _TokenGateEditorState createState() => _TokenGateEditorState();
}

class _TokenGateEditorState extends State<TokenGateEditor> {
  late TokenGateConfig _config;
  final _formKey = GlobalKey<FormState>();
  final _contractController = TextEditingController();
  final _tokenIdController = TextEditingController();
  final _minBalanceController = TextEditingController();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedType = 'nft';
  bool _isEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig ?? const TokenGateConfig(type: 'nft', isEnabled: true);

    _updateControllers();
  }

  void _updateControllers() {
    _contractController.text = _config.contract ?? '';
    _tokenIdController.text = _config.tokenId ?? '';
    _minBalanceController.text = _config.minBalance ?? '1';
    _nameController.text = _config.name ?? '';
    _symbolController.text = _config.symbol ?? '';
    _descriptionController.text = _config.description ?? '';
    _imageUrlController.text = _config.imageUrl ?? '';
    _selectedType = _config.type;
    _isEnabled = _config.isEnabled;
  }

  void _updateConfig() {
    _config = _config.copyWith(
      type: _selectedType,
      contract: _contractController.text.trim(),
      tokenId: _tokenIdController.text.trim(),
      minBalance: _minBalanceController.text.trim(),
      name: _nameController.text.trim(),
      symbol: _symbolController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      isEnabled: _isEnabled,
    );
  }

  Future<void> _fetchTokenMetadata() async {
    if (_contractController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final tokenGateService = await getTokenGateService();
      final contract = _contractController.text.trim();

      // Here you would typically fetch token metadata from a service
      // This is a simplified example
      final metadata = await _fetchMetadata(contract);

      if (metadata != null) {
        setState(() {
          _nameController.text = metadata['name'] ?? '';
          _symbolController.text = metadata['symbol'] ?? '';
          _descriptionController.text = metadata['description'] ?? '';
          _imageUrlController.text = metadata['image'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch token metadata: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _fetchMetadata(String contract) async {
    // Implement actual metadata fetching logic here
    // This is a placeholder implementation
    return {
      'name': 'NFT Collection',
      'symbol': 'NFT',
      'description': 'An NFT collection',
      'image': 'https://example.com/nft.png',
    };
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      _updateConfig();
      widget.onSave?.call(_config);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildTypeSelector(theme),
            const SizedBox(height: 16),
            _buildContractField(theme),
            if (_selectedType == 'nft') ..._buildNftFields(theme),
            if (_selectedType == 'token') ..._buildTokenFields(theme),
            _buildMetadataFields(theme),
            const SizedBox(height: 24),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.lock_outline, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'Token Gate Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Switch(
          value: _isEnabled,
          onChanged: (value) => setState(() => _isEnabled = value),
          activeThumbColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Token Type', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'nft',
              label: Text('NFT'),
              icon: Icon(Icons.image),
            ),
            ButtonSegment(
              value: 'token',
              label: Text('Token'),
              icon: Icon(Icons.account_balance_wallet),
            ),
            ButtonSegment(
              value: 'premium',
              label: Text('Premium'),
              icon: Icon(Icons.star),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (Set<String> selection) {
            setState(() => _selectedType = selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildContractField(ThemeData theme) {
    return TextFormField(
      controller: _contractController,
      decoration: InputDecoration(
        labelText: 'Contract Address',
        hintText: '0x...',
        border: const OutlineInputBorder(),
        suffixIcon: _contractController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.search),
                onPressed: _fetchTokenMetadata,
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a contract address';
        }
        // Add more validation if needed
        return null;
      },
    );
  }

  List<Widget> _buildNftFields(ThemeData theme) {
    return [
      const SizedBox(height: 16),
      TextFormField(
        controller: _tokenIdController,
        decoration: const InputDecoration(
          labelText: 'Token ID (optional)',
          hintText: 'Leave empty for any token from collection',
          border: OutlineInputBorder(),
        ),
      ),
    ];
  }

  List<Widget> _buildTokenFields(ThemeData theme) {
    return [
      const SizedBox(height: 16),
      TextFormField(
        controller: _minBalanceController,
        decoration: const InputDecoration(
          labelText: 'Minimum Balance',
          hintText: '1.0',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a minimum balance';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    ];
  }

  Widget _buildMetadataFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Token Metadata (optional)', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _symbolController,
          decoration: const InputDecoration(
            labelText: 'Symbol',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
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
              : const Text('SAVE'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _contractController.dispose();
    _tokenIdController.dispose();
    _minBalanceController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}

Future<void> showTokenGateEditor({
  required BuildContext context,
  TokenGateConfig? initialConfig,
  required Function(TokenGateConfig) onSave,
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Configure Token Gate'),
      content: TokenGateEditor(
        initialConfig: initialConfig,
        onSave: onSave,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
      ],
    ),
  );
}
