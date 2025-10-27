import 'package:flutter/material.dart';

import '../../services/i18n/internationalization_service.dart';

/// Виджет для выбора языка
class LanguageSelector extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  final bool showFlags;
  final bool showNativeNames;
  final String? selectedLanguage;

  const LanguageSelector({
    super.key,
    this.onLanguageChanged,
    this.showFlags = true,
    this.showNativeNames = false,
    this.selectedLanguage,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final InternationalizationService _i18nService = InternationalizationService();
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage ?? _i18nService.currentLanguage;

    // Подписываемся на изменения языка
    _i18nService.languageChangeStream.listen((languageCode) {
      if (mounted) {
        setState(() {
          _selectedLanguage = languageCode;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final supportedLanguages = _i18nService.supportedLanguages;

    return DropdownButtonFormField<String>(
      initialValue: _selectedLanguage,
      decoration: const InputDecoration(
        labelText: 'Language',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.language),
      ),
      items: supportedLanguages.map((language) {
        return DropdownMenuItem<String>(
          value: language.code,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showFlags)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              Text(
                widget.showNativeNames ? language.nativeName : language.name,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newLanguage) async {
        if (newLanguage != null && newLanguage != _selectedLanguage) {
          try {
            await _i18nService.setLanguage(newLanguage);
            setState(() {
              _selectedLanguage = newLanguage;
            });
            widget.onLanguageChanged?.call(newLanguage);
          } catch (e) {
            _showErrorSnackBar('Failed to change language: $e');
          }
        }
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Виджет для выбора языка в виде списка
class LanguageListSelector extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  final bool showFlags;
  final bool showNativeNames;
  final String? selectedLanguage;

  const LanguageListSelector({
    super.key,
    this.onLanguageChanged,
    this.showFlags = true,
    this.showNativeNames = false,
    this.selectedLanguage,
  });

  @override
  State<LanguageListSelector> createState() => _LanguageListSelectorState();
}

class _LanguageListSelectorState extends State<LanguageListSelector> {
  final InternationalizationService _i18nService = InternationalizationService();
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage ?? _i18nService.currentLanguage;

    // Подписываемся на изменения языка
    _i18nService.languageChangeStream.listen((languageCode) {
      if (mounted) {
        setState(() {
          _selectedLanguage = languageCode;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final supportedLanguages = _i18nService.supportedLanguages;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: supportedLanguages.length,
      itemBuilder: (context, index) {
        final language = supportedLanguages[index];
        final isSelected = language.code == _selectedLanguage;

        return ListTile(
          leading: widget.showFlags
              ? Text(
                  language.flag,
                  style: const TextStyle(fontSize: 24),
                )
              : null,
          title: Text(
            widget.showNativeNames ? language.nativeName : language.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: widget.showNativeNames ? Text(language.name) : null,
          trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
          selected: isSelected,
          onTap: () async {
            if (language.code != _selectedLanguage) {
              try {
                await _i18nService.setLanguage(language.code);
                setState(() {
                  _selectedLanguage = language.code;
                });
                widget.onLanguageChanged?.call(language.code);
              } catch (e) {
                _showErrorSnackBar('Failed to change language: $e');
              }
            }
          },
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Виджет для отображения текущего языка
class CurrentLanguageDisplay extends StatefulWidget {
  final bool showFlag;
  final bool showNativeName;
  final TextStyle? textStyle;

  const CurrentLanguageDisplay({
    super.key,
    this.showFlag = true,
    this.showNativeName = false,
    this.textStyle,
  });

  @override
  State<CurrentLanguageDisplay> createState() => _CurrentLanguageDisplayState();
}

class _CurrentLanguageDisplayState extends State<CurrentLanguageDisplay> {
  final InternationalizationService _i18nService = InternationalizationService();
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _currentLanguage = _i18nService.currentLanguage;

    // Подписываемся на изменения языка
    _i18nService.languageChangeStream.listen((languageCode) {
      if (mounted) {
        setState(() {
          _currentLanguage = languageCode;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = _i18nService.getLanguageByCode(_currentLanguage);

    if (language == null) {
      return const Text('Unknown Language');
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showFlag)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              language.flag,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        Text(
          widget.showNativeName ? language.nativeName : language.name,
          style: widget.textStyle ?? const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
