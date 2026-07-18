import 'dart:async';
import 'dart:html' as html;

bool currentNetworkOnline() => html.window.navigator.onLine ?? true;

Stream<bool> networkStatusStream() {
  late final StreamController<bool> controller;
  controller = StreamController<bool>.broadcast(
    onListen: () {
      controller.add(currentNetworkOnline());
    },
  );
  html.window.onOnline.listen((_) => controller.add(true));
  html.window.onOffline.listen((_) => controller.add(false));
  return controller.stream;
}
