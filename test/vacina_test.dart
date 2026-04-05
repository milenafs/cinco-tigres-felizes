import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/main.dart';
import 'package:cinco_tigres_felizes/screens/vacinacao_screen.dart';

void main() {
  testWidgets('opens vaccination screen from home button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Abrir Vacinação'), findsOneWidget);
    expect(find.byIcon(Icons.vaccines), findsOneWidget);

    await tester.tap(find.text('Abrir Vacinação'));
    await tester.pumpAndSettle();

    expect(find.byType(VacinacaoScreen), findsOneWidget);
  });
}
