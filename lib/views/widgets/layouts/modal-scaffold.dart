import 'package:flutter/material.dart';

class ModalScaffold extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final Widget? footer;
  final bool useSafeArea;

  const ModalScaffold({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) header!,
        Expanded(child: body),
        if (footer != null) footer!,
      ],
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      body: content,
    );
  }
}
