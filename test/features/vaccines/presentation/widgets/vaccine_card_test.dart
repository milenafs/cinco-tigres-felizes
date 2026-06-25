import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/vaccines/presentation/widgets/vaccine_card.dart';

void main() {
  testWidgets('renders title, description, dose and vaccine icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VacinaCard(
            titulo: 'BCG',
            descricao: 'Previne formas graves de tuberculose',
            doseTexto: 'Dose unica', 
            statusDoses: const [false], 
            isCompleta: false, 
            isEmProgresso: false,
            onDoseToggled: (index, isTomada) {}, 
          ),
        ),
      ),
    );

    expect(find.text('BCG'), findsOneWidget);
    expect(find.text('Previne formas graves de tuberculose'), findsOneWidget);
    expect(find.text('Dose recomendada: Dose unica'), findsOneWidget);
    
    expect(find.byIcon(Icons.vaccines), findsOneWidget);
    expect(find.text('Meu Progresso:'), findsOneWidget);
  });
}