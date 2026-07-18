import 'package:flutter/foundation.dart';

import 'image_picker_service.dart';

VoiceNoteRecorder createVoiceNoteRecorder() => VoiceNoteRecorder();

class VoiceNoteRecorder extends ChangeNotifier {
  bool get isSupported => false;
  bool get isPreparing => false;
  bool get isRecording => false;
  Duration get elapsed => Duration.zero;
  String? get errorMessage => 'Enregistrement vocal indisponible sur cet appareil.';
  String? get unavailableReason => errorMessage;

  Future<bool> start() async => false;

  Future<PickedMediaAttachment?> stop() async => null;

  Future<void> cancel() async {}

  Future<void> close() async {}
}
