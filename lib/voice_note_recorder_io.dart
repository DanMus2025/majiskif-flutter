import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'image_picker_service.dart';

VoiceNoteRecorder createVoiceNoteRecorder() => VoiceNoteRecorder();

class VoiceNoteRecorder extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isPreparing = false;
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  String? _errorMessage;
  Timer? _ticker;
  DateTime? _startedAt;
  String? _currentPath;

  bool get isSupported => true;
  bool get isPreparing => _isPreparing;
  bool get isRecording => _isRecording;
  Duration get elapsed => _elapsed;
  String? get errorMessage => _errorMessage;
  String? get unavailableReason => null;

  Future<bool> start() async {
    if (_isPreparing || _isRecording) return false;
    _errorMessage = null;
    _elapsed = Duration.zero;
    _isPreparing = true;
    notifyListeners();
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _errorMessage =
            "Le microphone n'est pas autorisé pour le moment. Vérifie l'autorisation micro puis réessaie.";
        _isPreparing = false;
        notifyListeners();
        return false;
      }
      final tempDir = await getTemporaryDirectory();
      final fileName = 'voice-note-${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = '${tempDir.path}${Platform.pathSeparator}$fileName';
      _currentPath = path;
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      _startedAt = DateTime.now();
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
        final startedAt = _startedAt;
        if (startedAt == null) return;
        _elapsed = DateTime.now().difference(startedAt);
        notifyListeners();
      });
      _isPreparing = false;
      _isRecording = true;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage =
          "Impossible de démarrer l'enregistrement vocal sur cet appareil.";
      _isPreparing = false;
      _isRecording = false;
      notifyListeners();
      return false;
    }
  }

  Future<PickedMediaAttachment?> stop() async {
    try {
      final path = await _recorder.stop();
      _ticker?.cancel();
      _ticker = null;
      _isRecording = false;
      _isPreparing = false;
      _startedAt = null;
      notifyListeners();
      final resolvedPath = path ?? _currentPath;
      if (resolvedPath == null || resolvedPath.isEmpty) return null;
      final file = File(resolvedPath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      return PickedMediaAttachment(
        dataUrl: 'data:audio/mp4;base64,${base64Encode(bytes)}',
        fileName: file.uri.pathSegments.isEmpty
            ? 'note-vocale-${DateTime.now().millisecondsSinceEpoch}.m4a'
            : file.uri.pathSegments.last,
        mimeType: 'audio/mp4',
      );
    } catch (_) {
      _errorMessage = "L'enregistrement vocal a échoué.";
      notifyListeners();
      return null;
    }
  }

  Future<void> cancel() async {
    try {
      await _recorder.cancel();
    } catch (_) {}
    await _cleanupCurrentFile();
    _ticker?.cancel();
    _ticker = null;
    _startedAt = null;
    _elapsed = Duration.zero;
    _isPreparing = false;
    _isRecording = false;
    notifyListeners();
  }

  Future<void> close() async {
    await cancel();
    await _recorder.dispose();
  }

  Future<void> _cleanupCurrentFile() async {
    final path = _currentPath;
    _currentPath = null;
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }
}
