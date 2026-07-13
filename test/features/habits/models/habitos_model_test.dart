import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/features/habits/models/habits_model.dart';

void main() {
  group('estaConcluidoEm', () {
    test('diário concluído retorna true', () {
      final hoje = DateTime.now();
      final chave = _chave(hoje);
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {chave: 1},
      );

      expect(habito.estaConcluidoEm(hoje), isTrue);
    });

    test('vezesPorDia concluído retorna true', () {
      final hoje = DateTime.now();
      final chave = _chave(hoje);
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 3,
        historico: {chave: 3},
      );

      expect(habito.estaConcluidoEm(hoje), isTrue);
    });

    test('vezesPorDia parcial retorna false', () {
      final hoje = DateTime.now();
      final chave = _chave(hoje);
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 3,
        historico: {chave: 2},
      );

      expect(habito.estaConcluidoEm(hoje), isFalse);
    });

    test('diário não concluído retorna false', () {
      final hoje = DateTime.now();
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      expect(habito.estaConcluidoEm(hoje), isFalse);
    });

    test('data sem registro retorna false', () {
      final hoje = DateTime.now();
      final ontem = hoje.subtract(const Duration(days: 1));
      final chaveOntem = _chave(ontem);
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {chaveOntem: 1},
      );

      expect(habito.estaConcluidoEm(hoje), isFalse);
    });
  });

  group('calcularStreak', () {
    DateTime hoje() => DateTime.now();
    String chave(DateTime d) => _chave(d);

    test('histórico vazio retorna 0', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      expect(habito.calcularStreak(), equals(0));
    });

    test('apenas hoje completo retorna 1', () {
      final d = hoje();
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {chave(d): 1},
      );

      expect(habito.calcularStreak(), equals(1));
    });

    test('5 dias consecutivos retorna 5', () {
      final d = hoje();
      final historico = <String, int>{};
      for (int i = 0; i < 5; i++) {
        historico[chave(d.subtract(Duration(days: i)))] = 1;
      }
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      expect(habito.calcularStreak(), equals(5));
    });

    test('8 dias consecutivos (streak > 6) retorna 8', () {
      final d = hoje();
      final historico = <String, int>{};
      for (int i = 0; i < 8; i++) {
        historico[chave(d.subtract(Duration(days: i)))] = 1;
      }
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      expect(habito.calcularStreak(), equals(8));
    });

    test('gap no meio interrompe a streak', () {
      final d = hoje();
      final historico = <String, int>{
        chave(d): 1,
        chave(d.subtract(const Duration(days: 1))): 1,
        // dia -2 está faltando
        chave(d.subtract(const Duration(days: 3))): 1,
        chave(d.subtract(const Duration(days: 4))): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      expect(habito.calcularStreak(), equals(2));
    });

    test('streak quebrada ontem retorna 1', () {
      final d = hoje();
      final historico = <String, int>{
        chave(d): 1,
        // ontem está faltando
        chave(d.subtract(const Duration(days: 2))): 1,
        chave(d.subtract(const Duration(days: 3))): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      expect(habito.calcularStreak(), equals(1));
    });

    test('vezesPorDia incompleto hoje retorna 0 mesmo com dias anteriores', () {
      final d = hoje();
      final historico = <String, int>{
        chave(d): 1, // apenas 1 de 3
        chave(d.subtract(const Duration(days: 1))): 3,
        chave(d.subtract(const Duration(days: 2))): 3,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 3,
        historico: historico,
      );

      expect(habito.calcularStreak(), equals(0));
    });

    test('streak longa com quebra no meio retorna até a quebra', () {
      final d = hoje();
      final historico = <String, int>{};
      for (int i = 0; i < 4; i++) {
        historico[chave(d.subtract(Duration(days: i)))] = 1;
      }
      // dia -4 está faltando
      for (int i = 5; i < 7; i++) {
        historico[chave(d.subtract(Duration(days: i)))] = 1;
      }
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      expect(habito.calcularStreak(), equals(4));
    });

    test('hoje vazio com dias antigos completos retorna 0', () {
      final d = hoje();
      final historico = <String, int>{
        chave(d.subtract(const Duration(days: 1))): 1,
        chave(d.subtract(const Duration(days: 2))): 1,
        chave(d.subtract(const Duration(days: 3))): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      expect(habito.calcularStreak(), equals(0));
    });
  });

  group('estaNaStreakAtual', () {
    DateTime hoje() => DateTime.now();
    String chave(DateTime d) => _chave(d);

    test('data dentro da streak retorna true', () {
      final d = hoje();
      final historico = <String, int>{
        chave(d): 1,
        chave(d.subtract(const Duration(days: 1))): 1,
        chave(d.subtract(const Duration(days: 2))): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      expect(
        habito.estaNaStreakAtual(d.subtract(const Duration(days: 1))),
        isTrue,
      );
    });

    test('streak = 0 retorna false', () {
      final d = hoje();
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      expect(habito.estaNaStreakAtual(d), isFalse);
    });

    test('data antes da streak retorna false', () {
      final d = hoje();
      final historico = <String, int>{
        chave(d): 1,
        chave(d.subtract(const Duration(days: 1))): 1,
        chave(d.subtract(const Duration(days: 2))): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      expect(
        habito.estaNaStreakAtual(d.subtract(const Duration(days: 3))),
        isFalse,
      );
    });

    test('data futura retorna false', () {
      final d = hoje();
      final historico = <String, int>{
        chave(d): 1,
        chave(d.subtract(const Duration(days: 1))): 1,
        chave(d.subtract(const Duration(days: 2))): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      expect(
        habito.estaNaStreakAtual(d.add(const Duration(days: 1))),
        isFalse,
      );
    });

    test('data na streak mas incompleta retorna false', () {
      final d = hoje();
      final historico = <String, int>{
        chave(d): 1,
        chave(d.subtract(const Duration(days: 1))): 1,
        chave(d.subtract(const Duration(days: 2))): 1,
      };
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      // dia -1 removido do histórico (incompleto)
      final habitoSemDia = habito.copyWith(
        historico: {
          chave(d): 1,
          chave(d.subtract(const Duration(days: 2))): 1,
        },
      );

      expect(
        habitoSemDia.estaNaStreakAtual(
          d.subtract(const Duration(days: 1)),
        ),
        isFalse,
      );
    });
  });

  group('Serialização maxStreak', () {
    test('toJson preserva maxStreak', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        maxStreak: 7,
      );

      final json = habito.toJson();

      expect(json['maxStreak'], equals(7));
    });

    test('fromJson preserva maxStreak', () {
      final json = {
        'id': '1',
        'nome': 'Teste',
        'tipo': 0,
        'vezesPorDia': 1,
        'historico': <String, int>{},
        'maxStreak': 7,
      };

      final habito = HabitoModel.fromJson(json);

      expect(habito.maxStreak, equals(7));
    });

    test('maxStreak padrão 0 quando ausente no JSON', () {
      final json = {
        'id': '1',
        'nome': 'Teste',
        'tipo': 0,
        'vezesPorDia': 1,
        'historico': <String, int>{},
      };

      final habito = HabitoModel.fromJson(json);

      expect(habito.maxStreak, equals(0));
    });
  });

  group('copyWith maxStreak', () {
    test('maxStreak é preservado no copyWith sem argumentos', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        maxStreak: 10,
      );

      final copia = habito.copyWith();

      expect(copia.maxStreak, equals(10));
    });

    test('maxStreak pode ser alterado via copyWith', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        maxStreak: 5,
      );

      final copia = habito.copyWith(maxStreak: 15);

      expect(copia.maxStreak, equals(15));
    });

    test('maxStreak mantém valor original se não fornecido', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        maxStreak: 8,
      );

      final copia = habito.copyWith(nome: 'Novo nome');

      expect(copia.maxStreak, equals(8));
    });
  });
}

String _chave(DateTime data) {
  final normalizado = DateTime(data.year, data.month, data.day);
  return normalizado.toIso8601String().split('T').first;
}