import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:majiskif/audio_attachment_player_io.dart' as audio_io;
import 'package:majiskif/image_picker_service_io.dart' as image_io;
import 'package:majiskif/url_action_service_io.dart' as url_io;
import 'package:majiskif/voice_note_recorder_io.dart' as voice_io;

void main() {
  testWidgets('android io service widgets compile', (tester) async {
    const attachment = image_io.PickedMediaAttachment(
      dataUrl: 'data:text/plain;base64,SGVsbG8=',
      fileName: 'hello.txt',
      mimeType: 'text/plain',
    );
    final recorder = voice_io.createVoiceNoteRecorder();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: audio_io.AudioAttachmentPlayer(
            dataUrl: 'data:audio/mp4;base64,AA==',
          ),
        ),
      ),
    );

    expect(attachment.fileName, 'hello.txt');
    expect(recorder.isSupported, isTrue);
    expect(url_io.openExternalUrl, isA<Function>());
  });
}
