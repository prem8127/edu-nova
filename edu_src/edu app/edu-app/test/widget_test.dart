import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edunova/main.dart';

void main() {
  testWidgets('EduNova launches into the login screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EduNovaApp()));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to EduNova'), findsOneWidget);
  });
}
