// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

Future<void> openExternalUrl(String url) async {
  html.window.open(url, '_blank');
}

Future<void> openBytesInNewTab(Uint8List bytes, String mimeType) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  Future<void>.delayed(
    const Duration(seconds: 20),
    () => html.Url.revokeObjectUrl(url),
  );
}

Future<void> printHtmlDocument(String title, String htmlBody) async {
  final isFullDocument = htmlBody.toLowerCase().contains('<html');
  final htmlContent = isFullDocument
      ? htmlBody.replaceFirst(
          RegExp(r'<body([^>]*)>', caseSensitive: false),
          '<body\$1 onload="window.print()">',
        )
      : '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>$title</title>
    <style>
      body { font-family: Arial, sans-serif; margin: 24px; color: #10251D; }
      .wrap { max-width: 720px; margin: 0 auto; }
      .row { display: flex; justify-content: space-between; margin: 6px 0; }
      .divider { border-top: 1px solid #d7e7df; margin: 12px 0; }
      h1,h2,h3,p { margin: 0; }
    </style>
  </head>
  <body onload="window.print()">
    <div class="wrap">$htmlBody</div>
  </body>
</html>
''';
  final blob = html.Blob([htmlContent], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  Future<void>.delayed(
    const Duration(seconds: 10),
    () => html.Url.revokeObjectUrl(url),
  );
}

Future<void> printPdfBytes(String title, Uint8List bytes) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final win = html.window.open(url, '_blank');
  Future<void>.delayed(
    const Duration(milliseconds: 900),
    () {
      try {
        if (win != null) {
          js_util.callMethod<Object?>(win, 'print', const []);
        }
      } catch (_) {}
    },
  );
  Future<void>.delayed(
    const Duration(seconds: 20),
    () => html.Url.revokeObjectUrl(url),
  );
}

Future<void> downloadBytes(String filename, Uint8List bytes, String mimeType) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
