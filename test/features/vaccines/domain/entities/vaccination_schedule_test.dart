import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';

void main() {
  group('Vacina', () {
    test('instancia com todos os campos obrigatórios', () {
      final vacina = Vacina(
        nome: 'BCG',
        descricao: 'Previne tuberculose',
        doseTexto: 'Dose única',
        quantidadeDeDoses: 1,
      );

      expect(vacina.nome, 'BCG');
      expect(vacina.descricao, 'Previne tuberculose');
      expect(vacina.doseTexto, 'Dose única');
      expect(vacina.quantidadeDeDoses, 1);
    });
  });

  group('CalendarioVacinas - selecionarLista', () {
    late CalendarioVacinas calendario;

    setUp(() {
      calendario = CalendarioVacinas(
        criancas: [
          Vacina(nome: 'BCG', descricao: '', doseTexto: 'Dose única', quantidadeDeDoses: 1),
          Vacina(nome: 'VIP', descricao: '', doseTexto: '3 doses', quantidadeDeDoses: 3),
        ],
        adolescentes: [
          Vacina(nome: 'HPV', descricao: '', doseTexto: '2 doses', quantidadeDeDoses: 2),
        ],
        adultos: [
          Vacina(nome: 'Dupla adulto', descricao: '', doseTexto: 'Reforço a cada 10 anos', quantidadeDeDoses: 10),
        ],
        gestantes: [
          Vacina(nome: 'Hepatite B', descricao: '', doseTexto: '3 doses', quantidadeDeDoses: 3),
          Vacina(nome: 'dTPa', descricao: '', doseTexto: '1 dose por gestação', quantidadeDeDoses: 1),
        ],
        idosos: [
          Vacina(nome: 'Pneumocócica 23V', descricao: '', doseTexto: '1 dose', quantidadeDeDoses: 1),
        ],
      );
    });

    test('seleciona grupo crianca_0_10', () {
      final resultado = calendario.selecionarLista('crianca_0_10');

      expect(resultado.length, 2);
      expect(resultado.map((v) => v.nome), containsAll(['BCG', 'VIP']));
    });

    test('seleciona grupo adolescente_11_19', () {
      final resultado = calendario.selecionarLista('adolescente_11_19');

      expect(resultado.length, 1);
      expect(resultado.first.nome, 'HPV');
    });

    test('seleciona grupo adulto_20_59', () {
      final resultado = calendario.selecionarLista('adulto_20_59');

      expect(resultado.length, 1);
      expect(resultado.first.nome, 'Dupla adulto');
    });

    test('seleciona grupo gestante', () {
      final resultado = calendario.selecionarLista('gestante');

      expect(resultado.length, 2);
      expect(resultado.map((v) => v.nome), containsAll(['Hepatite B', 'dTPa']));
      expect(resultado.map((v) => v.nome), isNot(contains('BCG')));
    });

    test('seleciona grupo idoso_60_mais', () {
      final resultado = calendario.selecionarLista('idoso_60_mais');

      expect(resultado.length, 1);
      expect(resultado.first.nome, 'Pneumocócica 23V');
    });

    test('chave inexistente retorna criancas por padrão', () {
      final resultado = calendario.selecionarLista('');

      expect(resultado.length, 2);
      expect(resultado.map((v) => v.nome), contains('BCG'));
    });

    test('chave desconhecida retorna criancas por padrão', () {
      final resultado = calendario.selecionarLista('categoria_invalida');

      expect(resultado, equals(calendario.criancas));
    });
  });
}
