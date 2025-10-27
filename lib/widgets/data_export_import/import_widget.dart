import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/data_export_import/bulk_operations_service.dart';
import '../../services/data_export_import/data_validation_service.dart' as validation_service;
import '../../services/data_import/data_import_service.dart' as import_service;
import '../../services/data_import/models/import_models.dart';

/// Виджет для импорта данных
class ImportWidget extends StatefulWidget {
  final Function(ImportResult)? onImportCompleted;
  final Function(String)? onError;
  final Map<String, dynamic>? schema;
  final List<BusinessRule>? businessRules;
  final bool validateBeforeImport;

  const ImportWidget({
    super.key,
    this.onImportCompleted,
    this.onError,
    this.schema,
    this.businessRules,
    this.validateBeforeImport = true,
  });

  @override
  State<ImportWidget> createState() => _ImportWidgetState();
}

class _ImportWidgetState extends State<ImportWidget> {
  final import_service.DataImportService _importService = import_service.DataImportService();
  final BulkOperationsService _bulkService = BulkOperationsService();

  List<String> _selectedFiles = [];
  ImportFormat? _selectedFormat;
  bool _validateSchema = true;
  bool _stopOnError = false;
  bool _isImporting = false;
  import_service.ImportResult? _lastResult;
  validation_service.ValidationResult? _validationResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Выбор файлов
            _buildFileSelection(),
            const SizedBox(height: 16),

            // Настройки импорта
            _buildImportSettings(),
            const SizedBox(height: 16),

            // Опции валидации
            _buildValidationOptions(),
            const SizedBox(height: 16),

            // Кнопки действий
            _buildActionButtons(),
            const SizedBox(height: 16),

            // Результат валидации
            if (_validationResult != null) _buildValidationResult(),

            // Результат импорта
            if (_lastResult != null) _buildImportResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Files',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectFiles,
                icon: const Icon(Icons.folder_open),
                label: const Text('Select Files'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _selectedFiles.isNotEmpty ? _clearFiles : null,
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ),
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Files (${_selectedFiles.length}):',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...(_selectedFiles.take(5).map((file) => Text(
                      '• ${file.split('/').last}',
                      style: const TextStyle(fontSize: 12),
                    ))),
                if (_selectedFiles.length > 5)
                  Text(
                    '... and ${_selectedFiles.length - 5} more',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImportSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Import Settings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ImportFormat>(
          decoration: const InputDecoration(
            labelText: 'File Format',
            border: OutlineInputBorder(),
          ),
          initialValue: _selectedFormat,
          hint: const Text('Auto-detect'),
          items: ImportFormat.values
              .where((format) => format != ImportFormat.unknown)
              .map((format) => DropdownMenuItem(
                    value: format,
                    child: Text(_getFormatName(format)),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedFormat = value),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Stop on Error'),
          subtitle: const Text('Stop importing if an error occurs'),
          value: _stopOnError,
          onChanged: (value) => setState(() => _stopOnError = value),
        ),
      ],
    );
  }

  Widget _buildValidationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validation Options',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Validate Schema'),
          subtitle: const Text('Validate data against schema'),
          value: _validateSchema,
          onChanged: (value) => setState(() => _validateSchema = value),
        ),
        if (widget.schema != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Schema validation is available',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectedFiles.isEmpty || _isImporting ? null : _validateFiles,
            icon: const Icon(Icons.verified_user),
            label: const Text('Validate'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectedFiles.isEmpty || _isImporting ? null : _importData,
            icon: _isImporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload),
            label: Text(_isImporting ? 'Importing...' : 'Import Data'),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationResult() {
    if (_validationResult == null) return const SizedBox.shrink();

    return Card(
      color: _validationResult!.isValid ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _validationResult!.isValid ? Icons.check_circle : Icons.warning,
                  color: _validationResult!.isValid ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  _validationResult!.isValid ? 'Validation Passed' : 'Validation Issues Found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _validationResult!.isValid ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            if (_validationResult!.errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Errors (${_validationResult!.errors.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...(_validationResult!.errors.take(5).map((error) => Text(
                    '• $error',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ))),
              if (_validationResult!.errors.length > 5)
                Text(
                  '... and ${_validationResult!.errors.length - 5} more errors',
                  style: const TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic),
                ),
            ],
            if (_validationResult!.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Warnings (${_validationResult!.warnings.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...(_validationResult!.warnings.take(3).map((warning) => Text(
                    '• $warning',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ))),
              if (_validationResult!.warnings.length > 3)
                Text(
                  '... and ${_validationResult!.warnings.length - 3} more warnings',
                  style: const TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImportResult() {
    if (_lastResult == null) return const SizedBox.shrink();

    return Card(
      color: _lastResult!.success ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _lastResult!.success ? Icons.check_circle : Icons.error,
                  color: _lastResult!.success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _lastResult!.success ? 'Import Successful' : 'Import Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _lastResult!.success ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (_lastResult!.success) ...[
              const SizedBox(height: 8),
              if (_lastResult!.recordCount != null) Text('Records imported: ${_lastResult!.recordCount}'),
              if (_lastResult!.metadata != null) Text('Format: ${_lastResult!.format}'),
            ] else if (_lastResult!.error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: ${_lastResult!.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFormatName(ImportFormat format) {
    switch (format) {
      case ImportFormat.json:
        return 'JSON';
      case ImportFormat.csv:
        return 'CSV';
      case ImportFormat.xml:
        return 'XML';
      case ImportFormat.unknown:
        return 'Unknown';
    }
  }

  Future<void> _selectFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['json', 'csv', 'xml'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files.map((file) => file.path!).toList();
        });
      }
    } catch (e) {
      widget.onError?.call('Failed to select files: $e');
    }
  }

  void _clearFiles() {
    setState(() {
      _selectedFiles.clear();
      _validationResult = null;
      _lastResult = null;
    });
  }

  Future<void> _validateFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      final List<import_service.ValidationResult> results = [];

      for (final String filePath in _selectedFiles) {
        final import_service.ValidationResult result = await _importService.validateFile(
          filePath: filePath,
          format: _selectedFormat,
          schema: widget.schema,
        );
        results.add(result);
      }

      // Объединяем результаты валидации
      final List<String> allErrors = [];
      final List<String> allWarnings = [];

      for (final import_service.ValidationResult result in results) {
        allErrors.addAll(result.errors);
        allWarnings.addAll(result.warnings);
      }

      setState(() {
        _validationResult = validation_service.ValidationResult(
          isValid: allErrors.isEmpty,
          errors: allErrors,
          warnings: allWarnings,
        );
      });
    } catch (e) {
      setState(() {
        _validationResult = validation_service.ValidationResult(
          isValid: false,
          errors: ['Validation failed: $e'],
          warnings: const [],
        );
      });
      widget.onError?.call(e.toString());
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importData() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      if (_selectedFiles.length == 1) {
        // Импорт одного файла
        final ImportResult result = await _importSingleFile(_selectedFiles.first);
        setState(() => _lastResult = result);
        widget.onImportCompleted?.call(result);
      } else {
        // Массовый импорт
        final BulkImportResult result = await _bulkService.bulkImport(
          filePaths: _selectedFiles,
          format: _selectedFormat,
          stopOnError: _stopOnError,
          validateBeforeImport: widget.validateBeforeImport,
          schema: widget.schema,
        );

        if (result.success && result.items.isNotEmpty) {
          // Показываем результат первого успешного импорта
          final BulkImportItem firstItem = result.items.firstWhere(
            (item) => item.success,
            orElse: () => result.items.first,
          );

          final ImportResult importResult = ImportResult(
            success: firstItem.success,
            data: firstItem.data,
            metadata: firstItem.metadata,
            recordCount: firstItem.recordCount,
            format: _selectedFormat ?? ImportFormat.unknown,
            error: firstItem.success ? null : 'Import failed',
          );

          setState(() => _lastResult = importResult);
          widget.onImportCompleted?.call(importResult);
        } else {
          final ImportResult errorResult = ImportResult(
            success: false,
            error: result.error ?? 'Bulk import failed',
            format: _selectedFormat ?? ImportFormat.unknown,
          );
          setState(() => _lastResult = errorResult);
          widget.onError?.call(result.error ?? 'Bulk import failed');
        }
      }
    } catch (e) {
      final ImportResult errorResult = ImportResult(
        success: false,
        error: e.toString(),
        format: _selectedFormat ?? ImportFormat.unknown,
      );
      setState(() => _lastResult = errorResult);
      widget.onError?.call(e.toString());
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<ImportResult> _importSingleFile(String filePath) async {
    switch (_selectedFormat ?? _detectFormat(filePath)) {
      case ImportFormat.json:
        return await _importService.importFromJson(
          filePath: filePath,
          validateSchema: _validateSchema,
          schema: widget.schema,
        );
      case ImportFormat.csv:
        return await _importService.importFromCsv(
          filePath: filePath,
          hasHeaders: true,
          validateData: true,
        );
      case ImportFormat.xml:
        return await _importService.importFromXml(
          filePath: filePath,
          validateSchema: _validateSchema,
          schema: widget.schema,
        );
      default:
        throw Exception('Unsupported import format');
    }
  }

  ImportFormat _detectFormat(String filePath) {
    final String extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'json':
        return ImportFormat.json;
      case 'csv':
        return ImportFormat.csv;
      case 'xml':
        return ImportFormat.xml;
      default:
        return ImportFormat.unknown;
    }
  }
}
