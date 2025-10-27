import 'package:flutter/material.dart';

class SearchHighlight extends StatelessWidget {
  final String text;
  final String searchTerm;
  final TextStyle? style;
  final Color? highlightColor;
  final Color? highlightBackgroundColor;
  final bool caseSensitive;

  const SearchHighlight({
    super.key,
    required this.text,
    required this.searchTerm,
    this.style,
    this.highlightColor,
    this.highlightBackgroundColor = Colors.yellow,
    this.caseSensitive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (searchTerm.isEmpty) {
      return Text(text, style: style);
    }

    final theme = Theme.of(context);
    final matches = _allMatches(text, searchTerm);
    if (matches.isEmpty) return Text(text, style: style);

    final spans = <TextSpan>[];
    var currentIndex = 0;

    for (final match in matches) {
      // Add text before the match
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: style,
        ));
      }

      // Add the highlighted match
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: style?.copyWith(
          color: highlightColor ?? theme.colorScheme.onSurface,
          backgroundColor: highlightBackgroundColor,
          fontWeight: FontWeight.bold,
        ),
      ));

      currentIndex = match.end;
    }

    // Add remaining text after the last match
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: style,
      ),
    );
  }

  List<Match> _allMatches(String text, String searchTerm) {
    final pattern = RegExp(
      RegExp.escape(searchTerm),
      caseSensitive: caseSensitive,
    );
    return pattern.allMatches(text).toList();
  }
}
