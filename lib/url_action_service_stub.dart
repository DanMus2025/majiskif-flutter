import 'dart:typed_data';

Future<void> openExternalUrl(String url) async {}

Future<void> openBytesInNewTab(Uint8List bytes, String mimeType) async {}

Future<void> printHtmlDocument(String title, String htmlBody) async {}

Future<void> printPdfBytes(String title, Uint8List bytes) async {}

Future<void> downloadBytes(String filename, Uint8List bytes, String mimeType) async {}
