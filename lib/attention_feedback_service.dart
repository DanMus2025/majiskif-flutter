import 'attention_feedback_service_stub.dart'
    if (dart.library.html) 'attention_feedback_service_web.dart';

abstract class AttentionFeedbackService {
  void notifyIncoming();
}

AttentionFeedbackService createAttentionFeedbackService() =>
    createAttentionFeedbackServiceImpl();
