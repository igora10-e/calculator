import 'package:calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Exibe a interface inicial da calculadora', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Calculadora'), findsOneWidget);

    final display = tester.widget<Text>(
      find.byKey(const Key('calculator-display')),
    );

    expect(display.data, '0');
    expect(find.byType(FilledButton), findsNWidgets(20));
    expect(tester.takeException(), isNull);
  });
}
