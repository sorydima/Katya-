import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../services/i18n/internationalization_service.dart';

/// Виджет для отображения переведенного текста
class TranslationWidget extends StatefulWidget {
  final String translationKey;
  final Map<String, dynamic>? parameters;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Widget? fallback;

  const TranslationWidget(
    this.translationKey, {
    super.key,
    this.parameters,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fallback,
  });

  @override
  State<TranslationWidget> createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
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
    final translation = _i18nService.translate(
      widget.translationKey,
      parameters: widget.parameters,
    );

    // Если перевод не найден, показываем fallback или ключ
    if (translation == widget.translationKey && widget.fallback != null) {
      return widget.fallback!;
    }

    return Text(
      translation,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

/// Виджет для отображения переведенного текста с плюрализацией
class PluralTranslationWidget extends StatefulWidget {
  final String translationKey;
  final int count;
  final Map<String, dynamic>? parameters;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Widget? fallback;

  const PluralTranslationWidget(
    this.translationKey,
    this.count, {
    super.key,
    this.parameters,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fallback,
  });

  @override
  State<PluralTranslationWidget> createState() => _PluralTranslationWidgetState();
}

class _PluralTranslationWidgetState extends State<PluralTranslationWidget> {
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
    final translation = _i18nService.translatePlural(
      widget.translationKey,
      widget.count,
      parameters: widget.parameters,
    );

    // Если перевод не найден, показываем fallback или ключ
    if (translation == widget.translationKey && widget.fallback != null) {
      return widget.fallback!;
    }

    return Text(
      translation,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

/// Виджет для отображения переведенного текста в RichText
class RichTranslationWidget extends StatefulWidget {
  final String translationKey;
  final Map<String, dynamic>? parameters;
  final List<TextSpan>? additionalSpans;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const RichTranslationWidget(
    this.translationKey, {
    super.key,
    this.parameters,
    this.additionalSpans,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<RichTranslationWidget> createState() => _RichTranslationWidgetState();
}

class _RichTranslationWidgetState extends State<RichTranslationWidget> {
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
    final translation = _i18nService.translate(
      widget.translationKey,
      parameters: widget.parameters,
    );

    final spans = <TextSpan>[
      TextSpan(text: translation),
      ...?widget.additionalSpans,
    ];

    return RichText(
      text: TextSpan(children: spans),
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

/// Виджет для отображения переведенного текста с поддержкой Markdown
class MarkdownTranslationWidget extends StatefulWidget {
  final String translationKey;
  final Map<String, dynamic>? parameters;
  final TextStyle? style;
  final TextAlign? textAlign;

  const MarkdownTranslationWidget(
    this.translationKey, {
    super.key,
    this.parameters,
    this.style,
    this.textAlign,
  });

  @override
  State<MarkdownTranslationWidget> createState() => _MarkdownTranslationWidgetState();
}

class _MarkdownTranslationWidgetState extends State<MarkdownTranslationWidget> {
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
    final translation = _i18nService.translate(
      widget.translationKey,
      parameters: widget.parameters,
    );

    // Простая обработка Markdown (можно расширить)
    return Text.rich(
      _parseMarkdown(translation),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }

  TextSpan _parseMarkdown(String text) {
    final spans = <TextSpan>[];
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '*' && i + 1 < text.length && text[i + 1] == '*') {
        // Bold text
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString()));
          buffer.clear();
        }
        i++; // Skip next *

        final boldText = StringBuffer();
        while (i + 1 < text.length && !(text[i] == '*' && text[i + 1] == '*')) {
          boldText.write(text[i]);
          i++;
        }
        if (i + 1 < text.length) i++; // Skip next *

        spans.add(TextSpan(
          text: boldText.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (char == '_' && i + 1 < text.length && text[i + 1] == '_') {
        // Italic text
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString()));
          buffer.clear();
        }
        i++; // Skip next _

        final italicText = StringBuffer();
        while (i + 1 < text.length && !(text[i] == '_' && text[i + 1] == '_')) {
          italicText.write(text[i]);
          i++;
        }
        if (i + 1 < text.length) i++; // Skip next _

        spans.add(TextSpan(
          text: italicText.toString(),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString()));
    }

    return TextSpan(children: spans);
  }
}

/// Виджет для отображения переведенного текста с поддержкой ссылок
class LinkTranslationWidget extends StatefulWidget {
  final String translationKey;
  final Map<String, dynamic>? parameters;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final Function(String)? onLinkTap;

  const LinkTranslationWidget(
    this.translationKey, {
    super.key,
    this.parameters,
    this.style,
    this.linkStyle,
    this.onLinkTap,
  });

  @override
  State<LinkTranslationWidget> createState() => _LinkTranslationWidgetState();
}

class _LinkTranslationWidgetState extends State<LinkTranslationWidget> {
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
    final translation = _i18nService.translate(
      widget.translationKey,
      parameters: widget.parameters,
    );

    return Text.rich(
      _parseLinks(translation),
      style: widget.style,
    );
  }

  TextSpan _parseLinks(String text) {
    final spans = <TextSpan>[];
    final buffer = StringBuffer();

    // Простая обработка ссылок в формате [text](url)
    final linkRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = linkRegex.allMatches(text);

    int lastEnd = 0;
    for (final match in matches) {
      // Добавляем текст до ссылки
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      // Добавляем ссылку
      final linkText = match.group(1)!;
      final linkUrl = match.group(2)!;

      spans.add(TextSpan(
        text: linkText,
        style: widget.linkStyle ??
            TextStyle(
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
            ),
        recognizer: TapGestureRecognizer()..onTap = () => widget.onLinkTap?.call(linkUrl),
      ));

      lastEnd = match.end;
    }

    // Добавляем оставшийся текст
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return TextSpan(children: spans);
  }
}
