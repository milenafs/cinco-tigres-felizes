import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinco_tigres_felizes/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('navega para a tela de hábitos a partir da home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hábitos'), findsOneWidget);
    await tester.tap(find.text('Hábitos'));
    await tester.pumpAndSettle();

    expect(find.text('Hábitos'), findsWidgets);
    expect(find.text('Nenhum hábito encontrado.'), findsOneWidget);
  });

  testWidgets('adiciona hábito e exibe cartão na lista', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Hábitos'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Meditar');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Meditar'), findsOneWidget);
    expect(find.text('Diário'), findsOneWidget);
  });

  testWidgets('marca conclusão de hoje e persiste entre reinícios', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Hábitos'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Exercício');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Exercício'), findsOneWidget);

    // Encontra e clica no botão de marcar hoje
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    // Agora deve mostrar o ícone de check (concluído)
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Recarrega o app para validar persistência
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hábitos'));
    await tester.pumpAndSettle();

    expect(find.text('Exercício'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
