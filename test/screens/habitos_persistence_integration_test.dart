import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinco_tigres_felizes/main.dart';

void main() {
  testWidgets('verifica SharedPreferences após marcar e reiniciar', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Hábitos'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Exercício');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar hábito'));
    await tester.pumpAndSettle();

    // marca hoje
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('habitos_lista');
    expect(stored, isNotNull);
    expect(stored, contains('Exercício'));

    // reinicia app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final prefs2 = await SharedPreferences.getInstance();
    final stored2 = prefs2.getString('habitos_lista');
    expect(stored2, isNotNull);
    expect(stored2, contains('Exercício'));
  });
}
