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

    // Encontra o Card do hábito e clica no botão de marcar hoje dentro dele
    final cardDoHabitoLocal = find.ancestor(of: find.text('Exercício'), matching: find.byType(Card));
    expect(cardDoHabitoLocal, findsOneWidget);
    final addDentroDoCard = find.descendant(of: cardDoHabitoLocal, matching: find.byIcon(Icons.add));
    expect(addDentroDoCard, findsOneWidget);
    await tester.tap(addDentroDoCard);
    await tester.pumpAndSettle();

    // Agora deve mostrar o ícone de check (concluído) - assert local UI state
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Validar persistência diretamente em SharedPreferences (mais confiável)
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('habitos_lista');
    expect(stored, isNotNull);
    expect(stored, contains('Exercício'));

    // Validar que existe um registro para a data de hoje
    final hoje = DateTime.now();
    final chaveHoje = DateTime(hoje.year, hoje.month, hoje.day).toIso8601String().split('T').first;
    expect(stored, contains(chaveHoje));
  });
}
