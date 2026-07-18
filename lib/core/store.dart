export 'store_interface.dart';
import 'store_interface.dart';

import 'store_io.dart' if (dart.library.html) 'store_web.dart' as impl;

AppStore createAppStore() => impl.createAppStore();
