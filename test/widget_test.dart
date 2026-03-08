import 'package:flutter_test/flutter_test.dart';

import 'package:sudomia/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SudomiaApp());

    expect(find.text('Sudomia'), findsOneWidget);
    expect(find.text('Sudoku'), findsOneWidget);
    expect(find.text('Mental Calc'), findsOneWidget);
    expect(find.text('CrossMath'), findsOneWidget);
  });
}
