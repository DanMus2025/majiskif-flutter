import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> openExternalUrl(String url) async {}

Future<void> openBytesInNewTab(Uint8List bytes, String mimeType) async {
  final file = await _writeTempFile(
    'document-${DateTime.now().millisecondsSinceEpoch}${_extensionForMimeType(mimeType)}',
    bytes,
  );
  await OpenFilex.open(file.path);
}

Future<void> printHtmlDocument(String title, String htmlBody) async {
  final file = await _writeTempFile(
    '${_sanitizeBaseName(title)}.html',
    Uint8List.fromList(htmlBody.codeUnits),
  );
  await OpenFilex.open(file.path);
}

Future<void> printPdfBytes(String title, Uint8List bytes) async {
  final file = await _writeTempFile(
    '${_sanitizeBaseName(title)}.pdf',
    bytes,
  );
  final result = await OpenFilex.open(file.path);
  if (result.type.name.toLowerCase() != 'done') {
    await Share.shareXFiles([XFile(file.path)], text: title);
  }
}

Future<void> downloadBytes(String filename, Uint8List bytes, String mimeType) async {
  final file = await _writeTempFile(filename, bytes);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: mimeType, name: file.uri.pathSegments.last)],
    text: file.uri.pathSegments.last,
  );
}

Future<File> _writeTempFile(String filename, Uint8List bytes) async {
  final directory = await getTemporaryDirectory();
  final safeName = filename.trim().isEmpty
      ? 'document-${DateTime.now().millisecondsSinceEpoch}'
      : filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  final file = File('${directory.path}${Platform.pathSeparator}$safeName');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

String _sanitizeBaseName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'document';
  return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
}

String _extensionForMimeType(String mimeType) {
  return switch (mimeType) {
    'application/pdf' => '.pdf',
    'text/html' => '.html',
    'image/png' => '.png',
    'image/jpeg' => '.jpg',
    _ => '.bin',
  };
}
