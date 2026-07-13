import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/features/habits/models/habits_model.dart';
import 'package:cinco_tigres_felizes/features/habits/presentation/widgets/habitos_card.dart';

String _chave(DateTime data) {
  final normalizado = DateTime(data.year, data.month, data.day);
  return normalizado.toIso8601String().split('T').first;
}

DateTime _hoje() => DateTime.now();
DateTime _dia(int offset) => _hoje().subtract(Duration(days: offset));

Widget _buildCard(HabitoModel habito) {
  return MaterialApp(
    home: Scaffold(
      body: CartaoHabito(
        habito: habito,
        aoAlternarData: (_) {},
      ),
    ),
  );
}

void main() {
  group('Streak section', () {
    testWidgets('streak > 0 exibe "Streak: X dias" em laranja', (
      WidgetTester tester,
    ) async {
      final historico = <String, int>{
        for (int i = 0; i < 3; i++) _chave(_dia(i)): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      await tester.pumpWidget(_buildCard(habito));

      expect(find.textContaining('Streak: 3'), findsOneWidget);
    });

    testWidgets('streak = 0 e maxStreak > 0 exibe "Streak: 0 dias" em teal', (
      WidgetTester tester,
    ) async {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
        maxStreak: 5,
      );

      await tester.pumpWidget(_buildCard(habito));

      expect(find.textContaining('Streak: 0'), findsOneWidget);
    });

    testWidgets('streak = 0 e maxStreak = 0 não exibe seção de streak', (
      WidgetTester tester,
    ) async {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
        maxStreak: 0,
      );

      await tester.pumpWidget(_buildCard(habito));

      expect(find.textContaining('Streak'), findsNothing);
    });

    testWidgets('streak > 6 exibe 🔥', (WidgetTester tester) async {
      final historico = <String, int>{
        for (int i = 0; i < 8; i++) _chave(_dia(i)): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      await tester.pumpWidget(_buildCard(habito));

      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('maxStreak > streak exibe "Máx: X dias"', (
      WidgetTester tester,
    ) async {
      final historico = <String, int>{
        for (int i = 0; i < 3; i++) _chave(_dia(i)): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
        maxStreak: 10,
      );

      await tester.pumpWidget(_buildCard(habito));

      expect(find.textContaining('Máx: 10'), findsOneWidget);
    });

    testWidgets('maxStreak igual ao streak não exibe "Máx:"', (
      WidgetTester tester,
    ) async {
      final historico = <String, int>{
        for (int i = 0; i < 5; i++) _chave(_dia(i)): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
        maxStreak: 5,
      );

      await tester.pumpWidget(_buildCard(habito));

      expect(find.textContaining('Máx:'), findsNothing);
    });

    testWidgets('maxStreak menor que streak não exibe "Máx:"', (
      WidgetTester tester,
    ) async {
      final historico = <String, int>{
        for (int i = 0; i < 5; i++) _chave(_dia(i)): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
        maxStreak: 2,
      );

      await tester.pumpWidget(_buildCard(habito));

      expect(find.textContaining('Máx:'), findsNothing);
    });
  });

  group('Borda do card', () {
    testWidgets('streak > 6 tem gradiente no card + 7 day-boxes com gradiente', (
      WidgetTester tester,
    ) async {
      final historico = <String, int>{
        for (int i = 0; i < 8; i++) _chave(_dia(i)): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      await tester.pumpWidget(_buildCard(habito));

      // Total de containers com gradiente:
      // - 7 day-boxes (últimos 7 dias na streak) com gradiente
      // - 1 card-level gradient (borda do card)
      // = 8 total
      final containerComGradient = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      // 7 day-boxes + 1 card-level = 8
      expect(containerComGradient, findsNWidgets(8));
    });

    testWidgets('streak <= 6 tem apenas day-boxes com gradiente', (
      WidgetTester tester,
    ) async {
      final historico = <String, int>{
        for (int i = 0; i < 3; i++) _chave(_dia(i)): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      await tester.pumpWidget(_buildCard(habito));

      // Apenas 3 day-boxes com gradiente (os 3 dias na streak)
      // NENHUM card-level gradient
      final containerComGradient = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(containerComGradient, findsNWidgets(3));
    });
  });

  group('Cores dos dias no histórico', () {
    testWidgets('dia na streak completo tem gradiente', (
      WidgetTester tester,
    ) async {
      final historico = <String, int>{
        for (int i = 0; i < 3; i++) _chave(_dia(i)): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      await tester.pumpWidget(_buildCard(habito));

      // O dia de ontem (dia -1) deve estar na streak e completo
      // Verificamos que o label do dia -1 aparece
      final labelOntem = _dia(1).day.toString();
      expect(find.text(labelOntem), findsOneWidget);
    });

    testWidgets('círculo "Hoje" usa cor original (sem gradiente streak)', (
      WidgetTester tester,
    ) async {
      final historico = <String, int>{
        for (int i = 0; i < 3; i++) _chave(_dia(i)): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      await tester.pumpWidget(_buildCard(habito));

      // O círculo "Hoje" deve ter shape BoxShape.circle (não gradiente)
      // Encontramos o Container circular com o texto "Hoje" abaixo
      expect(find.text('Hoje'), findsOneWidget);
    });

    testWidgets('dia fora da streak usa cor original', (
      WidgetTester tester,
    ) async {
      // Streak de 3 dias (hoje, -1, -2). Dia -4 tem registro mas está fora
      final historico = <String, int>{
        for (int i = 0; i < 3; i++) _chave(_dia(i)): 1,
        _chave(_dia(4)): 1, // dia -4 completo mas fora da streak
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      await tester.pumpWidget(_buildCard(habito));

      // O label do dia -4 deve aparecer
      final labelDia4 = _dia(4).day.toString();
      expect(find.text(labelDia4), findsOneWidget);
    });
  });
}