import 'dart:typed_data';

import 'package:flutter/widgets.dart';

class PdfDocumentPreview extends StatelessWidget {
  const PdfDocumentPreview({
    super.key,
    required this.bytes,
    required this.height,
    required this.fallback,
  });

  final Uint8List bytes;
  final double height;
  final Widget fallback;

  @override
  Widget build(BuildContext context) => fallback;
}

class HtmlDocumentPreview extends StatelessWidget {
  const HtmlDocumentPreview({
    super.key,
    required this.htmlDocument,
    required this.height,
    required this.fallback,
  });

  final String htmlDocument;
  final double height;
  final Widget fallback;

  @override
  Widget build(BuildContext context) => fallback;
}
