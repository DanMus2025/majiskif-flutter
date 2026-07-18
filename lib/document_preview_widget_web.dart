// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui_web' as ui;
import 'dart:html' as html;

import 'package:flutter/widgets.dart';

int _previewCounter = 0;

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
  Widget build(BuildContext context) {
    final viewType = 'pdf-preview-${_previewCounter++}';
    final src =
        'data:application/pdf;base64,${base64Encode(bytes)}#toolbar=0&navpanes=0&scrollbar=0';
    ui.platformViewRegistry.registerViewFactory(viewType, (int _) {
      return html.IFrameElement()
        ..src = src
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#FFFFFF';
    });
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final viewType = 'html-preview-${_previewCounter++}';
    ui.platformViewRegistry.registerViewFactory(viewType, (int _) {
      return html.IFrameElement()
        ..srcdoc = htmlDocument
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#FFFFFF';
    });
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }
}
