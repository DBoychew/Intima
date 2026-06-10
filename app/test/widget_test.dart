import 'package:flutter_test/flutter_test.dart';

import 'package:intima/main.dart';

void main() {
  testWidgets('Onboarding smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IntimaApp());
    await tester.pumpAndSettle();

    expect(find.text('Само твое.'), findsOneWidget);
    expect(find.text('Продължи'), findsOneWidget);
  });
}
