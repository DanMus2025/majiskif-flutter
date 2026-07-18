import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Lecture audio indisponible sur cet appareil.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
