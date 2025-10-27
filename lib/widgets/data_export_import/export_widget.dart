import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/data_export/data_export_service.dart';
import '../../services/data_export_import/bulk_operations_service.dart';

/// Виджет для экспорта данных
class ExportWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String? defaultFileName;
  final List<ExportFormat>? availableFormats;
  final Function(ExportResult)? onExportCompleted;
  final Function(String)? onError;

  const ExportWidget({
    super.key,
    this.data,
    this.defaultFileName,
    this.availableFormats,
    this.onExportCompleted,
    this.onError,
  });

  @override
  State<ExportWidget> createState() => _ExportWidgetState();
}

class _ExportWidgetState extends State<ExportWidget> {
  final DataExportService _exportService = DataExportService();
  final BulkOperationsService _bulkService = BulkOperationsService();

  List<ExportFormat> _selectedFormats = [ExportFormat.json];
  String _fileName = '';
  String _outputPath = '';
  bool _includeMetadata = true;
  bool _prettyPrint = true;
  bool _isExporting = false;
  ExportResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _fileName = widget.defaultFileName ?? 'export_${DateTime.now().millisecondsSinceEpoch}';
    _selectedFormats = widget.availableFormats ?? [ExportFormat.json, ExportFormat.csv, ExportFormat.xml];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Выбор форматов
            _buildFormatSelection(),
            const SizedBox(height: 16),

            // Настройки файла
            _buildFileSettings(),
            const SizedBox(height: 16),

            // Дополнительные опции
            _buildExportOptions(),
            const SizedBox(height: 16),

            // Кнопки действий
            _buildActionButtons(),
            const SizedBox(height: 16),

            // Результат экспорта
            if (_lastResult != null) _buildExportResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Formats',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ExportFormat.values
              .where((format) => format != ExportFormat.unknown)
              .map((format) => FilterChip(
                    label: Text(_getFormatName(format)),
                    selected: _selectedFormats.contains(format),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFormats.add(format);
                        } else {
                          _selectedFormats.remove(format);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFileSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Settings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'File Name',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: _fileName),
          onChanged: (value) => _fileName = value,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Output Path (optional)',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _outputPath),
                onChanged: (value) => _outputPath = value,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _selectOutputPath,
              child: const Text('Browse'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Options',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Include Metadata'),
          subtitle: const Text('Add export metadata to files'),
          value: _includeMetadata,
          onChanged: (value) => setState(() => _includeMetadata = value),
        ),
        SwitchListTile(
          title: const Text('Pretty Print'),
          subtitle: const Text('Format JSON/XML with indentation'),
          value: _prettyPrint,
          onChanged: (value) => setState(() => _prettyPrint = value),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isExporting ? null : _exportData,
            icon: _isExporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isExporting ? 'Exporting...' : 'Export Data'),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportWithBulkOptions,
          icon: const Icon(Icons.batch_prediction),
          label: const Text('Bulk Export'),
        ),
      ],
    );
  }

  Widget _buildExportResult() {
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
                  _lastResult!.success ? 'Export Successful' : 'Export Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _lastResult!.success ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (_lastResult!.success) ...[
              const SizedBox(height: 8),
              if (_lastResult!.filePath != null) Text('File: ${_lastResult!.filePath}'),
              if (_lastResult!.fileSize != null) Text('Size: ${_formatFileSize(_lastResult!.fileSize!)}'),
              if (_lastResult!.recordCount != null) Text('Records: ${_lastResult!.recordCount}'),
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

  String _getFormatName(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.xml:
        return 'XML';
      case ExportFormat.unknown:
        return 'Unknown';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _selectOutputPath() async {
    try {
      final String? selectedPath = await FilePicker.platform.getDirectoryPath();
      if (selectedPath != null) {
        setState(() => _outputPath = selectedPath);
      }
    } catch (e) {
      widget.onError?.call('Failed to select output path: $e');
    }
  }

  Future<void> _exportData() async {
    if (widget.data == null) {
      widget.onError?.call('No data to export');
      return;
    }

    setState(() => _isExporting = true);

    try {
      final Map<String, dynamic> metadata = _includeMetadata
          ? {
              'exportedAt': DateTime.now().toIso8601String(),
              'formats': _selectedFormats.map((f) => f.toString()).toList(),
              'fileName': _fileName,
            }
          : {};

      if (_selectedFormats.length == 1) {
        // Экспорт в один формат
        final ExportResult result = await _exportSingleFormat(
          _selectedFormats.first,
          metadata,
        );
        setState(() => _lastResult = result);
        widget.onExportCompleted?.call(result);
      } else {
        // Экспорт в несколько форматов
        final List<ExportResult> results = await _exportService.exportToMultipleFormats(
          data: widget.data!,
          baseFileName: _fileName,
          outputPath: _outputPath.isEmpty ? null : _outputPath,
          formats: _selectedFormats,
          metadata: metadata,
        );

        // Показываем результат первого успешного экспорта или первой ошибки
        final ExportResult firstResult = results.firstWhere(
          (result) => result.success,
          orElse: () => results.first,
        );
        setState(() => _lastResult = firstResult);
        widget.onExportCompleted?.call(firstResult);
      }
    } catch (e) {
      final ExportResult errorResult = ExportResult(
        success: false,
        error: e.toString(),
        format: _selectedFormats.first,
      );
      setState(() => _lastResult = errorResult);
      widget.onError?.call(e.toString());
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<ExportResult> _exportSingleFormat(
    ExportFormat format,
    Map<String, dynamic> metadata,
  ) async {
    switch (format) {
      case ExportFormat.json:
        return await _exportService.exportToJson(
          data: widget.data!,
          fileName: _fileName,
          outputPath: _outputPath.isEmpty ? null : _outputPath,
          prettyPrint: _prettyPrint,
          metadata: metadata,
        );
      case ExportFormat.csv:
        // Конвертируем данные в формат CSV
        final List<Map<String, dynamic>> csvData = _convertToCsvFormat(widget.data!);
        return await _exportService.exportToCsv(
          data: csvData,
          fileName: _fileName,
          outputPath: _outputPath.isEmpty ? null : _outputPath,
          metadata: metadata,
        );
      case ExportFormat.xml:
        return await _exportService.exportToXml(
          data: widget.data!,
          fileName: _fileName,
          outputPath: _outputPath.isEmpty ? null : _outputPath,
          prettyPrint: _prettyPrint,
          metadata: metadata,
        );
      default:
        throw Exception('Unsupported export format: $format');
    }
  }

  Future<void> _exportWithBulkOptions() async {
    if (widget.data == null) {
      widget.onError?.call('No data to export');
      return;
    }

    setState(() => _isExporting = true);

    try {
      final Map<String, dynamic> metadata = _includeMetadata
          ? {
              'exportedAt': DateTime.now().toIso8601String(),
              'formats': _selectedFormats.map((f) => f.toString()).toList(),
              'fileName': _fileName,
              'bulkExport': true,
            }
          : {};

      final BulkExportResult result = await _bulkService.bulkExport(
        dataSource: widget.data!,
        baseFileName: _fileName,
        outputPath: _outputPath.isEmpty ? null : _outputPath,
        formats: _selectedFormats,
        metadata: metadata,
      );

      if (result.success && result.items.isNotEmpty) {
        // Показываем результат первого элемента
        final BulkExportItem firstItem = result.items.first;
        if (firstItem.results.isNotEmpty) {
          setState(() => _lastResult = firstItem.results.first);
          widget.onExportCompleted?.call(firstItem.results.first);
        }
      } else {
        final ExportResult errorResult = ExportResult(
          success: false,
          error: result.error ?? 'Bulk export failed',
          format: _selectedFormats.first,
        );
        setState(() => _lastResult = errorResult);
        widget.onError?.call(result.error ?? 'Bulk export failed');
      }
    } catch (e) {
      final ExportResult errorResult = ExportResult(
        success: false,
        error: e.toString(),
        format: _selectedFormats.first,
      );
      setState(() => _lastResult = errorResult);
      widget.onError?.call(e.toString());
    } finally {
      setState(() => _isExporting = false);
    }
  }

  List<Map<String, dynamic>> _convertToCsvFormat(Map<String, dynamic> data) {
    // Простая конвертация для демонстрации
    final List<Map<String, dynamic>> result = [];

    if (data.isNotEmpty) {
      final Map<String, dynamic> firstItem =
          data.values.first is Map ? data.values.first as Map<String, dynamic> : {'value': data.values.first};
      result.add(firstItem);
    }

    return result;
  }
}
