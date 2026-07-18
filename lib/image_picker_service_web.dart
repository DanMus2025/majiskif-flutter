// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

class PickedMediaAttachment {
  const PickedMediaAttachment({
    required this.dataUrl,
    required this.fileName,
    required this.mimeType,
  });

  final String dataUrl;
  final String fileName;
  final String mimeType;
}

Future<String?> pickImageDataUrl() async {
  final picked = await pickMediaAttachment(accept: 'image/*');
  return picked?.dataUrl;
}

Future<PickedMediaAttachment?> pickMediaAttachment({
  String accept = '*/*',
  String? capture,
}) async {
  final completer = Completer<String?>();
  final input = html.FileUploadInputElement()..accept = accept;
  if (capture != null && capture.trim().isNotEmpty) {
    input.setAttribute('capture', capture);
  }
  input.click();

  input.onChange.first.then((_) {
    final file = input.files?.first;
    if (file == null) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onLoad.first.then((_) {
      if (!completer.isCompleted) {
        completer.complete(reader.result as String?);
      }
    });
    reader.onError.first.then((_) {
      if (!completer.isCompleted) completer.complete(null);
    });
  });

  final dataUrl = await completer.future;
  final file = input.files?.first;
  if (dataUrl == null || file == null) return null;
  return PickedMediaAttachment(
    dataUrl: dataUrl,
    fileName: file.name,
    mimeType: file.type.isEmpty ? 'application/octet-stream' : file.type,
  );
}
