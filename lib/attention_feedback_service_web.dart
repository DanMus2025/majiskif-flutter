import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:flutter/services.dart';

import 'attention_feedback_service.dart';

class _WebAttentionFeedbackService implements AttentionFeedbackService {
  @override
  void notifyIncoming() {
    SystemSound.play(SystemSoundType.alert);
    final navigator = html.window.navigator;
    if (js_util.hasProperty(navigator, 'vibrate')) {
      js_util.callMethod<dynamic>(navigator, 'vibrate', [140]);
    }
  }
}

AttentionFeedbackService createAttentionFeedbackServiceImpl() =>
    _WebAttentionFeedbackService();
