import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinco_tigres_felizes/screens/visualizacao_agua_screen.dart';

void main() {
  testWidgets('Deve exibir estado vazio quando não houver horário salvo', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: VisualizacaoAguaScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum lembrete cadastrado'), findsOneWidget);
  });

  testWidgets('Deve exibir o horário formatado corretamente quando houver JSON salvo', (WidgetTester tester) async {
    // 1. O JSON deve ter as chaves exatas: horaInicio, minutoInicio, horaFim, minutoFim, frequencia
    SharedPreferences.setMockInitialValues({
      'horario_agua': '{"horaInicio": 8, "minutoInicio": 30, "horaFim": 10, "minutoFim": 45, "frequencia": 45}'
    });

    await tester.pumpWidget(const MaterialApp(home: VisualizacaoAguaScreen()));
    
    // 2. O pumpAndSettle sozinho pode falhar em capturar o setState do Future
    await tester.pumpAndSettle();
    await tester.pump(); // O "pulo do gato": força o rebuild após o Future completar

    // 3. Verifica a string exatamente como montada na tela
    expect(find.text('Das 08:30 às 10:45, a cada 45 min'), findsOneWidget);
  });
}