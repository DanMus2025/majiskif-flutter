import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class AudioAttachmentPlayer extends StatefulWidget {
  const AudioAttachmentPlayer({
    super.key,
    required this.dataUrl,
    this.compact = false,
  });

  final String dataUrl;
  final bool compact;

  @override
  State<AudioAttachmentPlayer> createState() => _AudioAttachmentPlayerState();
}

class _AudioAttachmentPlayerState extends State<AudioAttachmentPlayer> {
  bool _opening = false;

  Future<void> _openAudio() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final resolved = _decodeDataUrl(widget.dataUrl);
      if (resolved == null) return;
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}${Platform.pathSeparator}note-vocale-${DateTime.now().millisecondsSinceEpoch}${resolved.extension}',
      );
      await file.writeAsBytes(resolved.bytes, flush: true);
      await OpenFilex.open(file.path);
    } finally {
      if (mounted) {
        setState(() => _opening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 10 : 12,
        vertical: widget.compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_outline_rounded),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _opening ? 'Ouverture de la note...' : 'Ouvrir la note vocale',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _opening ? null : _openAudio,
            child: const Text('Écouter'),
          ),
        ],
      ),
    );
  }
}

({List<int> bytes, String extension})? _decodeDataUrl(String dataUrl) {
  final commaIndex = dataUrl.indexOf(',');
  if (commaIndex <= 0) return null;
  final metadata = dataUrl.substring(0, commaIndex);
  final encoded = dataUrl.substring(commaIndex + 1);
  final mimeType =
      RegExp(r'^data:([^;]+)').firstMatch(metadata)?.group(1) ?? 'audio/mp4';
  final extension = switch (mimeType) {
    'audio/mpeg' => '.mp3',
    'audio/wav' => '.wav',
    'audio/ogg' => '.ogg',
    'audio/aac' => '.aac',
    'audio/webm' => '.webm',
    _ => '.m4a',
  };
  return (bytes: base64Decode(encoded), extension: extension);
}
