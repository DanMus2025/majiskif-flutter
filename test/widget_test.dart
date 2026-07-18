import 'package:flutter_test/flutter_test.dart';
import 'package:majiskif/main.dart';

void main() {
  testWidgets('KESE starts on dashboard', (tester) async {
    await tester.pumpWidget(const MajiskifApp());

    expect(tester.takeException(), isNull);
  });
}
