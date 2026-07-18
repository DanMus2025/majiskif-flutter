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

Future<String?> pickImageDataUrl() async => null;

Future<PickedMediaAttachment?> pickMediaAttachment({
  String accept = '*/*',
  String? capture,
}) async => null;
