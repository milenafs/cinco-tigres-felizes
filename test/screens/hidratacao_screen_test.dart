import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/habits/presentation/pages/hydration_page.dart';
import 'package:provider/provider.dart'; 
import 'package:cinco_tigres_felizes/features/habits/services/hydration_service.dart';
void main() {
  testWidgets('Deve exibir a meta inicial e porcentagem zero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => HidratacaoService(),
          child: const HidratacaoScreen(),
        ),
      ),
    );

    // Verifica se encontra o texto de 0%
    expect(find.text('0%'), findsOneWidget);

    // Verifica se o número 2000 (meta padrão) aparece
    expect(find.textContaining('2000'), findsOneWidget);

    // Verifica se os botões existem pelo texto simples
    expect(find.textContaining('Copo'), findsOneWidget);
    expect(find.textContaining('Garrafa'), findsOneWidget);
  });
}
