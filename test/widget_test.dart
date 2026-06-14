import 'package:flutter_test/flutter_test.dart';
import 'package:gb_chat/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ZenoApp());
    expect(find.text('ZENO'), findsOneWidget);
  });
}
