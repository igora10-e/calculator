import 'package:calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pressKeys(WidgetTester tester, List<String> labels) async {
  for (final label in labels) {
    final button = label == '⌫'
        ? find.widgetWithIcon(FilledButton, Icons.backspace_outlined)
        : find.widgetWithText(FilledButton, label);

    await tester.tap(button);
    await tester.pump();
  }
}

String displayValue(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('calculator-display'))).data!;
}

Future<void> openHistory(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Histórico'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Exibe o visor e as 18 teclas', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Calculadora'), findsOneWidget);
    expect(displayValue(tester), '0');
    expect(find.byType(FilledButton), findsNWidgets(18));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Executa as quatro operações', (tester) async {
    await tester.pumpWidget(const MyApp());

    final operations = {'+': '10', '−': '6', '×': '16', '÷': '4'};

    for (final operation in operations.entries) {
      await pressKeys(tester, ['C', '8', operation.key, '2', '=']);
      expect(displayValue(tester), operation.value);
    }
  });

  testWidgets('Aceita vírgula e ignora vírgula duplicada', (tester) async {
    await tester.pumpWidget(const MyApp());

    await pressKeys(tester, ['1', ',', ',', '5', '+', '2', '=']);

    expect(displayValue(tester), '3,5');
  });

  testWidgets('Apaga o último dígito e limpa o visor', (tester) async {
    await tester.pumpWidget(const MyApp());

    await pressKeys(tester, ['5', '0', '9', '⌫']);
    expect(displayValue(tester), '50');

    await pressKeys(tester, ['C']);
    expect(displayValue(tester), '0');
  });

  testWidgets('Executa operações em sequência', (tester) async {
    await tester.pumpWidget(const MyApp());

    await pressKeys(tester, ['2', '+', '3', '×', '4', '=']);

    expect(displayValue(tester), '20');
  });

  testWidgets('Permite corrigir o operador', (tester) async {
    await tester.pumpWidget(const MyApp());

    await pressKeys(tester, ['8', '+', '×', '2', '=']);

    expect(displayValue(tester), '16');
  });

  testWidgets('Trata divisão por zero e permite novo cálculo', (tester) async {
    await tester.pumpWidget(const MyApp());

    await pressKeys(tester, ['8', '÷', '0', '=']);
    expect(displayValue(tester), 'Erro');

    await pressKeys(tester, ['2', '+', '3', '=']);
    expect(displayValue(tester), '5');
  });

  testWidgets('Mostra mensagem quando o histórico está vazio', (tester) async {
    await tester.pumpWidget(const MyApp());

    await openHistory(tester);

    expect(find.text('Nenhuma operação realizada.'), findsOneWidget);
  });

  testWidgets('Preserva histórico ao limpar e ao voltar da tela', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await pressKeys(tester, ['8', '÷', '2', '=', 'C']);
    await openHistory(tester);

    expect(find.text('8 ÷ 2 = 4'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(displayValue(tester), '0');

    await pressKeys(tester, ['1', ',', '5', '+', '2', '=']);
    await openHistory(tester);

    expect(find.text('8 ÷ 2 = 4'), findsOneWidget);
    expect(find.text('1,5 + 2 = 3,5'), findsOneWidget);

    final newest = tester.getTopLeft(find.text('1,5 + 2 = 3,5'));
    final oldest = tester.getTopLeft(find.text('8 ÷ 2 = 4'));

    expect(newest.dy, lessThan(oldest.dy));
  });

  testWidgets('Não registra divisão por zero no histórico', (tester) async {
    await tester.pumpWidget(const MyApp());

    await pressKeys(tester, ['8', '÷', '0', '=']);
    await openHistory(tester);

    expect(find.text('Nenhuma operação realizada.'), findsOneWidget);
  });
}
