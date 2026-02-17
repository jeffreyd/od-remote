import 'package:flutter_test/flutter_test.dart';
import 'package:od_remote/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const OdRemoteApp());
    expect(find.text('OD Remote'), findsOneWidget);
  });
}
