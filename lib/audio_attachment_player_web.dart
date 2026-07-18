// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/widgets.dart';

int _audioAttachmentPlayerCounter = 0;

class AudioAttachmentPlayer extends StatelessWidget {
  const AudioAttachmentPlayer({
    super.key,
    required this.dataUrl,
    this.compact = false,
  });

  final String dataUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final viewType = 'audio-attachment-${_audioAttachmentPlayerCounter++}';
    ui.platformViewRegistry.registerViewFactory(viewType, (int _) {
      return html.AudioElement()
        ..src = dataUrl
        ..controls = true
        ..preload = 'metadata'
        ..style.width = '100%'
        ..style.height = compact ? '44px' : '54px'
        ..style.outline = 'none'
        ..style.border = '0'
        ..style.backgroundColor = 'transparent';
    });
    return SizedBox(
      height: compact ? 44 : 54,
      child: HtmlElementView(viewType: viewType),
    );
  }
}
