import 'package:flutter/services.dart';

import 'attention_feedback_service.dart';

class _StubAttentionFeedbackService implements AttentionFeedbackService {
  @override
  void notifyIncoming() {
    SystemSound.play(SystemSoundType.alert);
  }
}

AttentionFeedbackService createAttentionFeedbackServiceImpl() =>
    _StubAttentionFeedbackService();
