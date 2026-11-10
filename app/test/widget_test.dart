import 'package:flutter_test/flutter_test.dart';

import 'package:login_app/main.dart';

void main() {
  testWidgets('Pngumpul loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PngumpulApp());
    expect(find.text('Pngumpul'), findsWidgets);
  });
}
