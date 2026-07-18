import 'package:flutter/widgets.dart';

import 'core/app.dart';
import 'core/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  runApp(MajiskifApp(controller: controller));
}
