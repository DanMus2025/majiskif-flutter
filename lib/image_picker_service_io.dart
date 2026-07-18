import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

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

final ImagePicker _imagePicker = ImagePicker();

Future<String?> pickImageDataUrl() async {
  final picked = await pickMediaAttachment(accept: 'image/*');
  return picked?.dataUrl;
}

Future<PickedMediaAttachment?> pickMediaAttachment({
  String accept = '*/*',
  String? capture,
}) async {
  if (accept.contains('image/')) {
    return _pickImageAttachment(capture: capture);
  }
  final fileType = accept.contains('audio/')
      ? FileType.audio
      : accept.contains('image/')
      ? FileType.image
      : FileType.any;
  final result = await FilePicker.platform.pickFiles(
    type: fileType,
    withData: true,
  );
  final file =
      result == null || result.files.isEmpty ? null : result.files.first;
  if (file == null) return null;
  final bytes = file.bytes ?? await _readFileBytes(file.path);
  if (bytes == null || bytes.isEmpty) return null;
  final mimeType = _inferMimeType(
    file.extension ?? _extensionFromName(file.name),
    fallback: fileType == FileType.audio
        ? 'audio/mpeg'
        : 'application/octet-stream',
  );
  return PickedMediaAttachment(
    dataUrl: 'data:$mimeType;base64,${base64Encode(bytes)}',
    fileName: file.name,
    mimeType: mimeType,
  );
}

Future<PickedMediaAttachment?> _pickImageAttachment({String? capture}) async {
  final source = (capture ?? '').trim().isNotEmpty
      ? ImageSource.camera
      : ImageSource.gallery;
  final file = await _imagePicker.pickImage(source: source);
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  if (bytes.isEmpty) return null;
  final extension = _extensionFromName(file.name.isEmpty ? file.path : file.name);
  final mimeType = _inferMimeType(extension, fallback: 'image/jpeg');
  return PickedMediaAttachment(
    dataUrl: 'data:$mimeType;base64,${base64Encode(bytes)}',
    fileName: file.name.isEmpty ? 'image-${DateTime.now().millisecondsSinceEpoch}.$extension' : file.name,
    mimeType: mimeType,
  );
}

Future<List<int>?> _readFileBytes(String? path) async {
  if (path == null || path.isEmpty) return null;
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}

String _extensionFromName(String name) {
  final dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return '';
  return name.substring(dot + 1).toLowerCase();
}

String _inferMimeType(String extension, {required String fallback}) {
  return switch (extension.toLowerCase()) {
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'bmp' => 'image/bmp',
    'svg' => 'image/svg+xml',
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls' => 'application/vnd.ms-excel',
    'xlsx' =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt' => 'application/vnd.ms-powerpoint',
    'pptx' =>
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'txt' => 'text/plain',
    'csv' => 'text/csv',
    'mp3' => 'audio/mpeg',
    'wav' => 'audio/wav',
    'ogg' => 'audio/ogg',
    'm4a' => 'audio/mp4',
    'aac' => 'audio/aac',
    'webm' => 'audio/webm',
    _ => fallback,
  };
}
