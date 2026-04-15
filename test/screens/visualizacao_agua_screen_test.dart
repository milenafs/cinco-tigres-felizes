import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinco_tigres_felizes/screens/visualizacao_agua_screen.dart';

void main() {
  testWidgets('Deve exibir estado vazio quando não houver horário salvo', (WidgetTester tester) async {
    // Simulando banco de dados vazio
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: VisualizacaoAguaScreen()));
    await tester.pumpAndSettle();

    // Verifica se o texto de "Empty State" aparece
    expect(find.text('Nenhum horário cadastrado'), findsOneWidget);
  });
}