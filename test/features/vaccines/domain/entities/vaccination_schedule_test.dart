import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';

void main() {
  group('Vacina', () {
    test('instancia com todos os campos obrigatórios', () {
      final vacina = Vacina(
        id: 'test_id_bcg',
        nome: 'BCG',
        descricao: 'Previne tuberculose',
        doseTexto: 'Dose única',
        quantidadeDeDoses: 1,
      );

      expect(vacina.id, 'test_id_bcg');
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
          Vacina(
            id: 'crianca_bcg',
            nome: 'BCG',
            descricao: '',
            doseTexto: 'Dose única',
            quantidadeDeDoses: 1,
          ),
          Vacina(
            id: 'crianca_vip',
            nome: 'VIP',
            descricao: '',
            doseTexto: '3 doses',
            quantidadeDeDoses: 3,
          ),
        ],
        adolescentes: [
          Vacina(
            id: 'adolescente_hpv',
            nome: 'HPV',
            descricao: '',
            doseTexto: '2 doses',
            quantidadeDeDoses: 2,
          ),
        ],
        adultos: [
          Vacina(
            id: 'adulto_dupla',
            nome: 'Dupla adulto',
            descricao: '',
            doseTexto: 'Reforço a cada 10 anos',
            quantidadeDeDoses: 10,
          ),
        ],
        gestantes: [
          Vacina(
            id: 'gestante_hep_b',
            nome: 'Hepatite B',
            descricao: '',
            doseTexto: '3 doses',
            quantidadeDeDoses: 3,
          ),
          Vacina(
            id: 'gestante_dtpa',
            nome: 'dTPa',
            descricao: '',
            doseTexto: '1 dose por gestação',
            quantidadeDeDoses: 1,
          ),
        ],
        idosos: [
          Vacina(
            id: 'idoso_pneumo',
            nome: 'Pneumocócica 23V',
            descricao: '',
            doseTexto: '1 dose',
            quantidadeDeDoses: 1,
          ),
        ],
      );
    });

    test('seleciona grupo crianca_0_10', () {
      final resultado = calendario.selecionarLista(CategoriaVacina.crianca);

      expect(resultado.length, 2);
      expect(resultado.map((v) => v.nome), containsAll(['BCG', 'VIP']));
    });

    test('seleciona grupo adolescente_11_19', () {
      final resultado = calendario.selecionarLista(CategoriaVacina.adolescente);

      expect(resultado.length, 1);
      expect(resultado.first.nome, 'HPV');
    });

    test('seleciona grupo adulto_20_59', () {
      final resultado = calendario.selecionarLista(CategoriaVacina.adulto);

      expect(resultado.length, 1);
      expect(resultado.first.nome, 'Dupla adulto');
    });

    test('seleciona grupo gestante', () {
      final resultado = calendario.selecionarLista(CategoriaVacina.gestante);

      expect(resultado.length, 2);
      expect(resultado.map((v) => v.nome), containsAll(['Hepatite B', 'dTPa']));
      expect(resultado.map((v) => v.nome), isNot(contains('BCG')));
    });

    test('seleciona grupo idoso_60_mais', () {
      final resultado = calendario.selecionarLista(CategoriaVacina.idoso);

      expect(resultado.length, 1);
      expect(resultado.first.nome, 'Pneumocócica 23V');
    });
  });
}
