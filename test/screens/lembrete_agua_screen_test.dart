import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/main.dart';
import 'package:cinco_tigres_felizes/screens/lembrete_agua_screen.dart';
import 'package:cinco_tigres_felizes/screens/cadastro_lembrete_agua_screen.dart';

void main() {
  testWidgets('opens water reminder screen from home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Lembrete de Água'), findsOneWidget);
    expect(find.byIcon(Icons.water_drop), findsWidgets);

    await tester.tap(find.text('Lembrete de Água'));
    await tester.pumpAndSettle();

    expect(find.byType(LembreteAguaScreen), findsOneWidget);
  });

  testWidgets('navigates to registration screen when button is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lembrete de Água'));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar novo lembrete'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.text('Adicionar novo lembrete'));
    await tester.pumpAndSettle();

    expect(find.byType(CadastroLembreteScreen), findsOneWidget);
  });

  testWidgets('displays error when frequency is invalid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lembrete de Água'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar novo lembrete'));
    await tester.pumpAndSettle();

    // Limpar os campos de frequência (deixá-los vazios ou com zero)
    await tester.enterText(
      find.byType(TextField).at(0),
      '0',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      '0',
    );

    await tester.pumpAndSettle();

    // Encontrar e clicar no botão de salvar
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Verificar se mensagem de erro é exibida
    expect(find.text('A frequência deve ser maior que zero'), findsOneWidget);  
  });

  testWidgets('displays error when frequency exceeds interval', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lembrete de Água'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar novo lembrete'));
    await tester.pumpAndSettle();

    // Inserir valores para que frequência seja maior que intervalo
    // Intervalo padrão: 8-22 = 14 horas = 840 minutos
    // Frequência: 15 horas = 900 minutos (maior que 840)
    await tester.enterText(
      find.byType(TextField).at(0),
      '15',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      '0',
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('A frequência não pode ser maior que o intervalo definido'), findsOneWidget);
  });
}
