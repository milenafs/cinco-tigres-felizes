import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/features/habits/models/habits_model.dart';

void main() {
  group('alternarConclusao - Particionamento em Classes de Equivalência', () {
    String chave(DateTime data) {
      final normalizado = DateTime(data.year, data.month, data.day);
      return normalizado.toIso8601String().split('T').first;
    }

    group('Tipo Diário', () {
      test('CE1: contagem 0 → deve marcar como concluído', () {
        final hoje = DateTime.now();
        final habito = HabitoModel(
          id: '1',
          nome: 'Teste',
          tipo: TipoFrequenciaHabito.diario,
          historico: {},
        );

        final atualizado = habito.alternarConclusao(hoje);
        expect(atualizado.estaConcluidoEm(hoje), isTrue);
        expect(atualizado.obterContagem(hoje), equals(1));
      });

      test('CE2: contagem 1 → deve desmarcar', () {
        final hoje = DateTime.now();
        final habito = HabitoModel(
          id: '1',
          nome: 'Teste',
          tipo: TipoFrequenciaHabito.diario,
          historico: {chave(hoje): 1},
        );

        final atualizado = habito.alternarConclusao(hoje);
        expect(atualizado.estaConcluidoEm(hoje), isFalse);
        expect(atualizado.obterContagem(hoje), equals(0));
      });

      test('CE2: contagem > 1 → deve desmarcar (comportamento idempotente)', () {
        final hoje = DateTime.now();
        final habito = HabitoModel(
          id: '1',
          nome: 'Teste',
          tipo: TipoFrequenciaHabito.diario,
          historico: {chave(hoje): 5},
        );

        final atualizado = habito.alternarConclusao(hoje);
        expect(atualizado.estaConcluidoEm(hoje), isFalse);
        expect(atualizado.obterContagem(hoje), equals(0));
      });
    });

    group('Tipo VezesPorDia', () {
      test('CE3: contagem < vezesPorDia → deve incrementar', () {
        final hoje = DateTime.now();
        final habito = HabitoModel(
          id: '1',
          nome: 'Teste',
          tipo: TipoFrequenciaHabito.vezesPorDia,
          vezesPorDia: 3,
          historico: {chave(hoje): 1},
        );

        final atualizado = habito.alternarConclusao(hoje);
        expect(atualizado.obterContagem(hoje), equals(2));
        expect(atualizado.estaConcluidoEm(hoje), isFalse);
      });

      test('CE3: contagem = vezesPorDia - 1 → deve incrementar e completar', () {
        final hoje = DateTime.now();
        final habito = HabitoModel(
          id: '1',
          nome: 'Teste',
          tipo: TipoFrequenciaHabito.vezesPorDia,
          vezesPorDia: 3,
          historico: {chave(hoje): 2},
        );

        final atualizado = habito.alternarConclusao(hoje);
        expect(atualizado.obterContagem(hoje), equals(3));
        expect(atualizado.estaConcluidoEm(hoje), isTrue);
      });

      test('CE4: contagem = vezesPorDia → deve desmarcar', () {
        final hoje = DateTime.now();
        final habito = HabitoModel(
          id: '1',
          nome: 'Teste',
          tipo: TipoFrequenciaHabito.vezesPorDia,
          vezesPorDia: 3,
          historico: {chave(hoje): 3},
        );

        final atualizado = habito.alternarConclusao(hoje);
        expect(atualizado.obterContagem(hoje), equals(0));
        expect(atualizado.estaConcluidoEm(hoje), isFalse);
      });

      test('CE5: contagem > vezesPorDia → deve desmarcar', () {
        final hoje = DateTime.now();
        final habito = HabitoModel(
          id: '1',
          nome: 'Teste',
          tipo: TipoFrequenciaHabito.vezesPorDia,
          vezesPorDia: 3,
          historico: {chave(hoje): 5},
        );

        final atualizado = habito.alternarConclusao(hoje);
        expect(atualizado.obterContagem(hoje), equals(0));
        expect(atualizado.estaConcluidoEm(hoje), isFalse);
      });
    });

    group('Comportamento Imutável', () {
      test('não modifica o hábito original', () {
        final hoje = DateTime.now();
        final habito = HabitoModel(
          id: '1',
          nome: 'Teste',
          tipo: TipoFrequenciaHabito.diario,
          historico: {},
        );

        final originalContagem = habito.obterContagem(hoje);
        habito.alternarConclusao(hoje);

        expect(habito.obterContagem(hoje), equals(originalContagem));
      });
    });
  });

  group('alternarConclusao - Análise de Valor Limite (vezesPorDia)', () {
    String chave(DateTime data) {
      final normalizado = DateTime(data.year, data.month, data.day);
      return normalizado.toIso8601String().split('T').first;
    }

    final hoje = DateTime.now();

    test('VL1: vezesPorDia = 1 (mínimo) - incremento único completa', () {
      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 1,
        historico: {},
      );

      // Primeira marcação
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(1));
      expect(habito.estaConcluidoEm(hoje), isTrue);

      // Segunda marcação desmarca
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(0));
      expect(habito.estaConcluidoEm(hoje), isFalse);
    });

    test('VL2: vezesPorDia = 2 - transição de 1 para 2 completa', () {
      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 2,
        historico: {chave(hoje): 1},
      );

      // Incremento de 1 para 2 completa
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(2));
      expect(habito.estaConcluidoEm(hoje), isTrue);

      // Próximo incremento desmarca
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(0));
      expect(habito.estaConcluidoEm(hoje), isFalse);
    });

    test('VL3: vezesPorDia = 3 - múltiplas marcações', () {
      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 3,
        historico: {},
      );

      // 1ª marcação
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(1));
      expect(habito.estaConcluidoEm(hoje), isFalse);

      // 2ª marcação
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(2));
      expect(habito.estaConcluidoEm(hoje), isFalse);

      // 3ª marcação completa
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(3));
      expect(habito.estaConcluidoEm(hoje), isTrue);

      // 4ª marcação desmarca
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(0));
      expect(habito.estaConcluidoEm(hoje), isFalse);
    });

    test('VL4: vezesPorDia = 10 (valor alto) - comportamento correto', () {
      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 10,
        historico: {chave(hoje): 9},
      );

      // 10ª marcação completa
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(10));
      expect(habito.estaConcluidoEm(hoje), isTrue);

      // 11ª marcação desmarca
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(0));
      expect(habito.estaConcluidoEm(hoje), isFalse);
    });

    test('Valor limite: vezesPorDia = 0 (inválido) - remove a chave', () {
      // vezesPorDia = 0 é um caso extremo
      // Quando contagem = 0 e vezesPorDia = 0: 0 < 0 é false, então remove a chave
      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 0,
        historico: {},
      );

      habito = habito.alternarConclusao(hoje);
      // A chave é removida, então contagem = 0
      expect(habito.obterContagem(hoje), equals(0));
      // 0 >= 0 é true, então estaConcluidoEm retorna true
      expect(habito.estaConcluidoEm(hoje), isTrue);
    });
  });

  group('alternarConclusao - Cenários Integrados', () {
    String chave(DateTime data) {
      final normalizado = DateTime(data.year, data.month, data.day);
      return normalizado.toIso8601String().split('T').first;
    }

    test('múltiplas datas com tipo diário', () {
      final hoje = DateTime.now();
      final ontem = hoje.subtract(const Duration(days: 1));

      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {chave(ontem): 1},
      );

      // Marcar hoje
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(1));
      expect(habito.obterContagem(ontem), equals(1));

      // Desmarcar hoje
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(0));
      expect(habito.obterContagem(ontem), equals(1)); // Ontem permanece
    });

    test('múltiplas datas com tipo vezesPorDia', () {
      final hoje = DateTime.now();
      final ontem = hoje.subtract(const Duration(days: 1));

      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 2,
        historico: {chave(ontem): 2},
      );

      // Marcar hoje (1 de 2)
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(1));
      expect(habito.obterContagem(ontem), equals(2));

      // Completar hoje (2 de 2)
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(2));
      expect(habito.estaConcluidoEm(hoje), isTrue);

      // Desmarcar hoje
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(0));
      expect(habito.obterContagem(ontem), equals(2)); // Ontem permanece
    });

    test('alternância completa: marcar e desmarcar várias vezes', () {
      final hoje = DateTime.now();

      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      // Ciclo 1: marcar
      habito = habito.alternarConclusao(hoje);
      expect(habito.estaConcluidoEm(hoje), isTrue);

      // Ciclo 2: desmarcar
      habito = habito.alternarConclusao(hoje);
      expect(habito.estaConcluidoEm(hoje), isFalse);

      // Ciclo 3: marcar novamente
      habito = habito.alternarConclusao(hoje);
      expect(habito.estaConcluidoEm(hoje), isTrue);

      // Ciclo 4: desmarcar novamente
      habito = habito.alternarConclusao(hoje);
      expect(habito.estaConcluidoEm(hoje), isFalse);
    });

    test('vezesPorDia: ciclo completo de marcações', () {
      final hoje = DateTime.now();

      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 3,
        historico: {},
      );

      // Incrementos até completar
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(1));

      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(2));

      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(3));
      expect(habito.estaConcluidoEm(hoje), isTrue);

      // Desmarcar
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(0));
      expect(habito.estaConcluidoEm(hoje), isFalse);

      // Reiniciar ciclo
      habito = habito.alternarConclusao(hoje);
      expect(habito.obterContagem(hoje), equals(1));
    });
  });

  group('alternarConclusao - Impacto no Streak', () {
    String chave(DateTime data) {
      final normalizado = DateTime(data.year, data.month, data.day);
      return normalizado.toIso8601String().split('T').first;
    }

    test('marcar hoje inicia streak de 1 dia', () {
      final hoje = DateTime.now();

      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      // Marcar hoje
      habito = habito.alternarConclusao(hoje);
      // Streak deve ser 1 (apenas hoje)
      expect(habito.calcularStreak(), equals(1));
    });

    test('desmarcar hoje quebra streak', () {
      final hoje = DateTime.now();

      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {chave(hoje): 1},
      );

      // Streak de 1 dia (apenas hoje)
      expect(habito.calcularStreak(), equals(1));

      habito = habito.alternarConclusao(hoje);
      // Ao desmarcar hoje, streak quebra
      expect(habito.calcularStreak(), equals(0));
    });

    test('desmarcar dia anterior não quebra streak de hoje', () {
      final hoje = DateTime.now();
      final ontem = hoje.subtract(const Duration(days: 1));

      var habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {chave(hoje): 1, chave(ontem): 1},
      );

      // Streak de 2 dias (ontem + hoje)
      expect(habito.calcularStreak(), equals(2));

      // Desmarcar ontem
      habito = habito.alternarConclusao(ontem);
      // Streak continua sendo 1 (apenas hoje)
      expect(habito.calcularStreak(), equals(1));
      expect(habito.estaConcluidoEm(hoje), isTrue);
    });
  });
}