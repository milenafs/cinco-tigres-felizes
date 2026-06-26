import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/vaccines/presentation/widgets/vaccine_card.dart';

void main() {
  Widget buildCard({
    String titulo = 'BCG',
    String descricao = 'Previne formas graves de tuberculose',
    String doseTexto = 'Dose única',
    List<bool> statusDoses = const [false],
    bool isCompleta = false,
    bool isEmProgresso = false,
    void Function(int, bool)? onDoseToggled,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: VacinaCard(
          titulo: titulo,
          descricao: descricao,
          doseTexto: doseTexto,
          statusDoses: statusDoses,
          isCompleta: isCompleta,
          isEmProgresso: isEmProgresso,
          onDoseToggled: onDoseToggled ?? (_, __) {},
        ),
      ),
    );
  }

  group('VacinaCard', () {
    testWidgets('exibe título, descrição, dosagem e ícone', (tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.text('BCG'), findsOneWidget);
      expect(find.text('Previne formas graves de tuberculose'), findsOneWidget);
      expect(find.text('Dose recomendada: Dose única'), findsOneWidget);
      expect(find.byIcon(Icons.vaccines), findsOneWidget);
      expect(find.text('Meu Progresso:'), findsOneWidget);
    });

    testWidgets('exibe um botão de dose para vacina com dose única', (tester) async {
      await tester.pumpWidget(buildCard(statusDoses: [false]));

      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('exibe três botões de dose para vacina com 3 doses', (tester) async {
      await tester.pumpWidget(buildCard(statusDoses: [false, false, false]));

      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));
    });

    testWidgets('exibe selo "Vacinação Completa" quando isCompleta é true', (tester) async {
      await tester.pumpWidget(buildCard(
        statusDoses: [true],
        isCompleta: true,
      ));

      expect(find.text('Vacinação Completa'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('exibe selo "Em Andamento" quando isEmProgresso é true', (tester) async {
      await tester.pumpWidget(buildCard(
        statusDoses: [true, false, false],
        isEmProgresso: true,
      ));

      expect(find.text('Em Andamento'), findsOneWidget);
      expect(find.byIcon(Icons.timelapse), findsOneWidget);
    });

    testWidgets('chama onDoseToggled ao tocar no botão de dose', (tester) async {
      int? indexChamado;
      bool? valorChamado;

      await tester.pumpWidget(buildCard(
        statusDoses: [false],
        onDoseToggled: (index, isTomada) {
          indexChamado = index;
          valorChamado = isTomada;
        },
      ));

      await tester.tap(find.byIcon(Icons.radio_button_unchecked));
      await tester.pump();

      expect(indexChamado, 0);
      expect(valorChamado, true);
    });
  });
}
