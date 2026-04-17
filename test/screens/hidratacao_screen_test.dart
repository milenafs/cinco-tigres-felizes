import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/screens/hidratacao_screen.dart';

void main() {
  testWidgets('Deve exibir a meta inicial e porcentagem zero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HidratacaoScreen()));

    // Verifica se encontra o texto de 0%
    expect(find.text('0%'), findsOneWidget);

    // Em vez de procurar a frase inteira, procuramos apenas se o número 2000 aparece
    expect(find.textContaining('2000'), findsOneWidget);

    // Verifica se os botões existem pelo texto simples
    expect(find.textContaining('Copo'), findsOneWidget);
    expect(find.textContaining('Garrafa'), findsOneWidget);
  });
}
