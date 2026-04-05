import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/widgets/vacina_card.dart';

void main() {
  testWidgets('renders title, description, dose and vaccine icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VacinaCard(
            titulo: 'BCG',
            descricao: 'Previne formas graves de tuberculose',
            dose: 'Dose unica',
          ),
        ),
      ),
    );

    expect(find.text('BCG'), findsOneWidget);
    expect(find.text('Previne formas graves de tuberculose'), findsOneWidget);
    expect(find.text('Dose: Dose unica'), findsOneWidget);
    expect(find.byIcon(Icons.vaccines), findsOneWidget);
  });
}
