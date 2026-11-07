// ============================================================================
// BloodNorms | test/widget_test.dart
// Basic smoke test for BloodNorms application
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bloodnorms/main.dart';

void main() {
  testWidgets('BloodNorms smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BloodNormsApp());
    expect(find.text('BloodNorms'), findsWidgets);
  });
}
