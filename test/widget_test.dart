import 'package:flutter_test/flutter_test.dart';

import 'package:sudova/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SudovaApp());

    expect(find.text('Sudova'), findsOneWidget);
    expect(find.text('Sudoku'), findsOneWidget);
    expect(find.text('Mental Calc'), findsOneWidget);
    expect(find.text('CrossMath'), findsOneWidget);
  });
}
