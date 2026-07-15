import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/features/habits/models/habits_model.dart';

void main() {
  group('obterPeriodosHistorico - Análise de Valor Limite', () {
    test('retorna exatamente 7 períodos (últimos 7 dias)', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      final periodos = habito.obterPeriodosHistorico();
      expect(periodos.length, equals(7));
    });

    test('períodos cobrem de -6 dias até hoje', () {
      final hoje = DateTime.now();
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      final periodos = habito.obterPeriodosHistorico();
      
      // Primeiro período deve ser de 6 dias atrás
      final primeiro = periodos.first;
      final esperadoPrimeiro = DateTime(hoje.year, hoje.month, hoje.day)
          .subtract(const Duration(days: 6));
      expect(
        DateTime(primeiro.data.year, primeiro.data.month, primeiro.data.day),
        equals(esperadoPrimeiro),
      );

      // Último período deve ser hoje
      final ultimo = periodos.last;
      final esperadoUltimo = DateTime(hoje.year, hoje.month, hoje.day);
      expect(
        DateTime(ultimo.data.year, ultimo.data.month, ultimo.data.day),
        equals(esperadoUltimo),
      );
    });

    test('datas estão em ordem crescente', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      final periodos = habito.obterPeriodosHistorico();
      
      for (int i = 1; i < periodos.length; i++) {
        expect(
          periodos[i].data.isAfter(periodos[i - 1].data) ||
              periodos[i].data.isAtSameMomentAs(periodos[i - 1].data),
          isTrue,
          reason: 'Período $i deve ser >= período ${i - 1}',
        );
      }
    });

    test('labels são strings de dia (1-31)', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      final periodos = habito.obterPeriodosHistorico();
      
      for (final periodo in periodos) {
        expect(periodo.label, matches(RegExp(r'^\d{1,2}$')));
        final dia = int.parse(periodo.label);
        expect(dia, greaterThanOrEqualTo(1));
        expect(dia, lessThanOrEqualTo(31));
      }
    });
  });

  group('obterPeriodosHistorico - Contagem e Total', () {
    String chave(DateTime data) {
      final normalizado = DateTime(data.year, data.month, data.day);
      return normalizado.toIso8601String().split('T').first;
    }

    test('tipo diário: total sempre 1', () {
      final hoje = DateTime.now();
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {chave(hoje): 1},
      );

      final periodos = habito.obterPeriodosHistorico();
      
      for (final periodo in periodos) {
        expect(periodo.total, equals(1));
      }
    });

    test('tipo vezesPorDia: total = vezesPorDia', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 5,
        historico: {},
      );

      final periodos = habito.obterPeriodosHistorico();
      
      for (final periodo in periodos) {
        expect(periodo.total, equals(5));
      }
    });

    test('contagem reflete o histórico corretamente', () {
      final hoje = DateTime.now();
      final ontem = hoje.subtract(const Duration(days: 1));
      final chaveHoje = chave(hoje);
      final chaveOntem = chave(ontem);

      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {
          chaveHoje: 1,
          chaveOntem: 1,
        },
      );

      final periodos = habito.obterPeriodosHistorico();
      
      // Último período (hoje) deve ter contagem 1
      expect(periodos.last.contagem, equals(1));
      expect(periodos.last.estaConcluido, isTrue);
      
      // Penúltimo período (ontem) deve ter contagem 1
      expect(periodos[periodos.length - 2].contagem, equals(1));
      expect(periodos[periodos.length - 2].estaConcluido, isTrue);
    });

    test('dias sem registro têm contagem 0', () {
      // Usar data fixa para evitar problemas com fuso horário
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      final periodos = habito.obterPeriodosHistorico();
      
      // Verificar apenas os dias que não são hoje
      for (int i = 0; i < periodos.length - 1; i++) {
        expect(periodos[i].contagem, equals(0));
        expect(periodos[i].estaConcluido, isFalse);
      }
    });
  });

  group('obterPeriodosHistorico - Percentual', () {
    String chave(DateTime data) {
      final normalizado = DateTime(data.year, data.month, data.day);
      return normalizado.toIso8601String().split('T').first;
    }

    test('percentual = 0 quando contagem = 0', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      final periodos = habito.obterPeriodosHistorico();
      
      for (final periodo in periodos) {
        expect(periodo.percentual, equals(0.0));
      }
    });

    test('percentual = 1.0 quando contagem = total', () {
      final hoje = DateTime.now();
      final chaveHoje = chave(DateTime(hoje.year, hoje.month, hoje.day));
      
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {chaveHoje: 1},
      );

      final periodos = habito.obterPeriodosHistorico();
      final hojePeriodo = periodos.last;
      
      expect(hojePeriodo.percentual, equals(1.0));
    });

    test('percentual calculado corretamente para vezesPorDia', () {
      final hoje = DateTime.now();
      final chaveHoje = chave(DateTime(hoje.year, hoje.month, hoje.day));
      
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 4,
        historico: {chaveHoje: 2},
      );

      final periodos = habito.obterPeriodosHistorico();
      final hojePeriodo = periodos.last;
      
      expect(hojePeriodo.contagem, equals(2));
      expect(hojePeriodo.total, equals(4));
      expect(hojePeriodo.percentual, equals(0.5));
    });

    test('percentual é clampado entre 0 e 1', () {
      final hoje = DateTime.now();
      final chaveHoje = chave(DateTime(hoje.year, hoje.month, hoje.day));
      
      // Mesmo com contagem > total, percentual deve ser 1.0
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {chaveHoje: 5},
      );

      final periodos = habito.obterPeriodosHistorico();
      final hojePeriodo = periodos.last;
      
      expect(hojePeriodo.percentual, equals(1.0));
    });
  });

  group('obterPeriodosHistorico - Pode Marcar', () {
    test('podeMarcar é true por padrão', () {
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: {},
      );

      final periodos = habito.obterPeriodosHistorico();
      
      for (final periodo in periodos) {
        expect(periodo.podeMarcar, isTrue);
      }
    });

    test('podeMarcar pode ser definido como false', () {
      final periodo = PeriodoHistorico(
        data: DateTime.now(),
        label: '15',
        contagem: 0,
        total: 1,
        podeMarcar: false,
      );

      expect(periodo.podeMarcar, isFalse);
    });
  });

  group('obterPeriodosHistorico - Cenários Reais', () {
    String chave(DateTime data) {
      final normalizado = DateTime(data.year, data.month, data.day);
      return normalizado.toIso8601String().split('T').first;
    }

    test('histórico completo de 7 dias', () {
      final hoje = DateTime.now();
      final historico = <String, int>{};
      
      for (int i = 0; i < 7; i++) {
        final data = DateTime(hoje.year, hoje.month, hoje.day)
            .subtract(Duration(days: i));
        historico[chave(data)] = 1;
      }

      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      final periodos = habito.obterPeriodosHistorico();
      
      expect(periodos.length, equals(7));
      
      // Todos os dias devem estar concluídos
      for (final periodo in periodos) {
        expect(periodo.contagem, equals(1));
        expect(periodo.estaConcluido, isTrue);
        expect(periodo.percentual, equals(1.0));
      }
    });

    test('histórico parcial com alguns dias faltando', () {
      final hoje = DateTime.now();
      final historico = <String, int>{};
      
      // Apenas hoje, -2 e -5
      final hojeKey = chave(hoje);
      final diaMenos2 = chave(hoje.subtract(const Duration(days: 2)));
      final diaMenos5 = chave(hoje.subtract(const Duration(days: 5)));
      
      historico[hojeKey] = 1;
      historico[diaMenos2] = 1;
      historico[diaMenos5] = 1;

      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.diario,
        historico: historico,
      );

      final periodos = habito.obterPeriodosHistorico();
      
      expect(periodos.length, equals(7));
      
      // Verificar que apenas 3 dias têm contagem
      final diasComContagem = periodos.where((p) => p.contagem > 0).length;
      expect(diasComContagem, equals(3));
    });

    test('vezesPorDia com conclusão parcial', () {
      final hoje = DateTime.now();
      final chaveHoje = chave(DateTime(hoje.year, hoje.month, hoje.day));
      
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 3,
        historico: {chaveHoje: 2},
      );

      final periodos = habito.obterPeriodosHistorico();
      
      // O último período é hoje
      final hojePeriodo = periodos.last;
      expect(hojePeriodo.contagem, equals(2));
      expect(hojePeriodo.total, equals(3));
      expect(hojePeriodo.percentual, equals(2 / 3));
      // estaConcluido retorna true para qualquer contagem > 0
      expect(hojePeriodo.estaConcluido, isTrue);
    });

    test('vezesPorDia completado em um dia', () {
      final hoje = DateTime.now();
      final chaveHoje = chave(DateTime(hoje.year, hoje.month, hoje.day));
      
      final habito = HabitoModel(
        id: '1',
        nome: 'Teste',
        tipo: TipoFrequenciaHabito.vezesPorDia,
        vezesPorDia: 3,
        historico: {chaveHoje: 3},
      );

      final periodos = habito.obterPeriodosHistorico();
      final hojePeriodo = periodos.last;
      
      expect(hojePeriodo.contagem, equals(3));
      expect(hojePeriodo.total, equals(3));
      expect(hojePeriodo.percentual, equals(1.0));
      expect(hojePeriodo.estaConcluido, isTrue);
    });
  });

  group('PeriodoHistorico - Propriedades', () {
    test('estaConcluido é true quando contagem > 0', () {
      final periodo = PeriodoHistorico(
        data: DateTime.now(),
        label: '15',
        contagem: 1,
        total: 1,
      );

      expect(periodo.estaConcluido, isTrue);
    });

    test('estaConcluido é false quando contagem = 0', () {
      final periodo = PeriodoHistorico(
        data: DateTime.now(),
        label: '15',
        contagem: 0,
        total: 1,
      );

      expect(periodo.estaConcluido, isFalse);
    });

    test('percentual é 0 quando total = 0', () {
      final periodo = PeriodoHistorico(
        data: DateTime.now(),
        label: '15',
        contagem: 0,
        total: 0,
      );

      expect(periodo.percentual, equals(0.0));
    });

    test('percentual é calculado corretamente', () {
      final periodo = PeriodoHistorico(
        data: DateTime.now(),
        label: '15',
        contagem: 3,
        total: 5,
      );

      expect(periodo.percentual, equals(0.6));
    });

    test('percentual é clampado a 1.0 quando contagem > total', () {
      final periodo = PeriodoHistorico(
        data: DateTime.now(),
        label: '15',
        contagem: 10,
        total: 5,
      );

      expect(periodo.percentual, equals(1.0));
    });

    test('percentual é clampado a 0.0 quando contagem < 0', () {
      final periodo = PeriodoHistorico(
        data: DateTime.now(),
        label: '15',
        contagem: -1,
        total: 5,
      );

      expect(periodo.percentual, equals(0.0));
    });
  });
}

String chave(DateTime data) {
  final normalizado = DateTime(data.year, data.month, data.day);
  return normalizado.toIso8601String().split('T').first;
}