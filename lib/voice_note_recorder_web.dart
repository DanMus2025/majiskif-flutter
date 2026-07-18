// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import 'image_picker_service.dart';

VoiceNoteRecorder createVoiceNoteRecorder() => VoiceNoteRecorder();

class VoiceNoteRecorder extends ChangeNotifier {
  static const html.EventStreamProvider<html.BlobEvent> _dataAvailableEvent =
      html.EventStreamProvider<html.BlobEvent>('dataavailable');
  static const html.EventStreamProvider<html.Event> _stopEvent =
      html.EventStreamProvider<html.Event>('stop');

  bool _isPreparing = false;
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  String? _errorMessage;
  html.MediaRecorder? _recorder;
  html.MediaStream? _stream;
  Timer? _ticker;
  DateTime? _startedAt;
  final List<html.Blob> _chunks = <html.Blob>[];

  bool get isSupported => true;
  bool get isPreparing => _isPreparing;
  bool get isRecording => _isRecording;
  Duration get elapsed => _elapsed;
  String? get errorMessage => _errorMessage;
  String? get unavailableReason =>
      _hasCompatibleWebMicrophoneOrigin ? null : _insecureOriginMessage;

  bool get _hasCompatibleWebMicrophoneOrigin {
    final protocol = html.window.location.protocol.toLowerCase();
    final host = (html.window.location.hostname ?? '').toLowerCase();
    final isLoopback =
        host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1' ||
        host == '[::1]';
    return protocol == 'https:' || isLoopback;
  }

  String get _insecureOriginMessage =>
      "Sur telephone, le micro n'est pas autorisable depuis cette adresse web. Ouvre l'application Android ou publie cette version en HTTPS.";

  Future<bool> start() async {
    if (_isPreparing || _isRecording) return false;
    _errorMessage = null;
    _elapsed = Duration.zero;
    _isPreparing = true;
    notifyListeners();
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      final stream = mediaDevices != null
          ? await mediaDevices.getUserMedia({
              'audio': true,
              'video': false,
            })
          : await html.window.navigator.getUserMedia(
              audio: true,
              video: false,
            );
      final recorder = html.MediaRecorder(stream);
      _stream = stream;
      _recorder = recorder;
      _chunks.clear();
      _dataAvailableEvent.forTarget(recorder).listen((event) {
        final blob = event.data;
        if (blob != null && blob.size > 0) {
          _chunks.add(blob);
        }
      });
      recorder.start();
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
    } catch (error) {
      await cancel();
      final raw = error.toString().toLowerCase();
      if (!_hasCompatibleWebMicrophoneOrigin) {
        _errorMessage = _insecureOriginMessage;
      } else if (raw.contains('notallowed') ||
          raw.contains('permission') ||
          raw.contains('denied')) {
        _errorMessage =
            "Le telephone ou le navigateur a refuse le micro. Autorise le micro pour ce site puis reessaie.";
      } else {
        _errorMessage =
            "Impossible d'acceder au microphone depuis ce navigateur. Verifie les permissions micro puis reessaie.";
      }
      _isPreparing = false;
      _isRecording = false;
      notifyListeners();
      return false;
    }
  }

  Future<PickedMediaAttachment?> stop() async {
    final recorder = _recorder;
    if (recorder == null) return null;
    final completer = Completer<PickedMediaAttachment?>();
    late final StreamSubscription<html.Event> stopSubscription;
    late final StreamSubscription<html.Event> errorSubscription;
    stopSubscription = _stopEvent.forTarget(recorder).listen((_) async {
      await stopSubscription.cancel();
      await errorSubscription.cancel();
      final mimeType = _normalizeMimeType(recorder.mimeType ?? 'audio/webm');
      final extension = _fileExtensionForMimeType(mimeType);
      final blob = html.Blob(_chunks, mimeType);
      final reader = html.FileReader();
      reader.readAsDataUrl(blob);
      reader.onLoad.first.then((_) async {
        await _cleanupRecorderState();
        final dataUrl = reader.result as String?;
        if (dataUrl == null || dataUrl.isEmpty) {
          if (!completer.isCompleted) completer.complete(null);
          return;
        }
        if (!completer.isCompleted) {
          completer.complete(
            PickedMediaAttachment(
              dataUrl: dataUrl,
              fileName:
                  'note-vocale-${DateTime.now().millisecondsSinceEpoch}.$extension',
              mimeType: mimeType,
            ),
          );
        }
      });
      reader.onError.first.then((_) async {
        await _cleanupRecorderState();
        if (!completer.isCompleted) completer.complete(null);
      });
    });
    errorSubscription = recorder.onError.listen((_) async {
      await stopSubscription.cancel();
      await errorSubscription.cancel();
      await _cleanupRecorderState();
      _errorMessage = "L'enregistrement vocal a echoue.";
      notifyListeners();
      if (!completer.isCompleted) completer.complete(null);
    });
    _isRecording = false;
    _isPreparing = false;
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
    recorder.stop();
    return completer.future;
  }

  Future<void> cancel() async {
    final recorder = _recorder;
    if (recorder != null && recorder.state != 'inactive') {
      recorder.stop();
    }
    await _cleanupRecorderState(clearChunks: true);
  }

  Future<void> close() async {
    await cancel();
  }

  Future<void> _cleanupRecorderState({bool clearChunks = false}) async {
    _ticker?.cancel();
    _ticker = null;
    _startedAt = null;
    _elapsed = Duration.zero;
    _recorder = null;
    final stream = _stream;
    _stream = null;
    if (stream != null) {
      for (final track in stream.getTracks()) {
        track.stop();
      }
    }
    if (clearChunks) {
      _chunks.clear();
    }
    _isPreparing = false;
    _isRecording = false;
    notifyListeners();
  }

  String _normalizeMimeType(String raw) {
    if (raw.trim().isEmpty) {
      return 'audio/webm';
    }
    return raw;
  }

  String _fileExtensionForMimeType(String mimeType) {
    if (mimeType.contains('ogg')) return 'ogg';
    if (mimeType.contains('mp4')) return 'm4a';
    if (mimeType.contains('mpeg')) return 'mp3';
    if (mimeType.contains('wav')) return 'wav';
    return 'webm';
  }
}
