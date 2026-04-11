import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/models/vacina_model.dart';

void main() {
  group('VacinaModel', () {
    test('fromJson and toJson maps fields correctly', () {
      final json = {
        'nome': 'BCG',
        'descricao': 'Previne tuberculose',
        'dose': 'Dose unica',
      };

      final model = VacinaModel.fromJson(json);

      expect(model.nome, 'BCG');
      expect(model.descricao, 'Previne tuberculose');
      expect(model.dose, 'Dose unica');
      expect(model.toJson(), json);
    });
  });

  group('VacinasCalendarioModel', () {
    test('parses groups from json payload', () {
      final json = {
        'crianca_0_10': [
          {
            'nome': 'BCG',
            'descricao': 'Previne tuberculose',
            'dose': 'Dose unica',
          },
        ],
        'adolescente_11_19': <Map<String, dynamic>>[],
        'adulto_20_59': <Map<String, dynamic>>[],
        'gestante': [
          {
            'nome': 'dTPa',
            'descricao': 'Previne difteria, tetano e coqueluche',
            'dose': '1 dose por gestacao',
          },
        ],
        'idoso_60_mais': <Map<String, dynamic>>[],
      };

      final calendario = VacinasCalendarioModel.fromJson(json);

      expect(calendario.criancas.length, 1);
      expect(calendario.criancas.first.nome, 'BCG');
      expect(calendario.gestantes.length, 1);
      expect(calendario.gestantes.first.nome, 'dTPa');
    });
  });

  group('VacinasCalendarioModel - Filtros', () {
    test('Selecting "gestante" group', () {
      final vacinaG1 = VacinaModel(nome: 'Hepatite B', descricao: 'Previne hepatite B', dose: '3 doses');
      final vacinaG2 = VacinaModel(nome: 'dTPa', descricao: 'Previne difteria, tétano e coqueluche', dose: '1 dose por gestação');
      final vacinaC1 = VacinaModel(nome: 'BCG', descricao: 'Previne formas graves de tuberculose', dose: 'Dose única');

      final calendario = VacinasCalendarioModel(
        criancas: [vacinaC1],
        adolescentes: [],
        adultos: [],
        gestantes: [vacinaG1, vacinaG2],
        idosos: [],
      );

      // Aplica o filtro
      final resultado = calendario.selecionarLista('gestante');

      expect(resultado.length, 2);
      final nomes = resultado.map((v) => v.nome).toList();
      expect(nomes, containsAll(['Hepatite B', 'dTPa']));
      expect(nomes, isNot(contains('BCG')));
    });

    test('Selecting "crianca" group', () {
      final vacinaC1 = VacinaModel(nome: 'Hepatite B', descricao: 'Previne hepatite B', dose: '3 doses');
      final vacinaC2 = VacinaModel(nome: 'BCG', descricao: 'Previne formas graves de tuberculose', dose: 'Dose única');
      final vacinaC3 = VacinaModel(nome: 'VIP (Poliomielite inativada)', descricao: 'Previne poliomielite', dose: '1ª, 2ª e 3ª doses');

      final calendario = VacinasCalendarioModel(
        criancas: [vacinaC1, vacinaC2, vacinaC3],
        adolescentes: [],
        adultos: [],
        gestantes: [],
        idosos: [],
      );

      // Aplica o filtro
      final resultado = calendario.selecionarLista('crianca');

      expect(resultado.length, 3);
      final nomes = resultado.map((v) => v.nome).toList();
      expect(nomes, containsAll(['Hepatite B', 'BCG', 'VIP (Poliomielite inativada)']));
    });
  
    test('Selecting "idosos" group', () {
      final vacina1 = VacinaModel(nome: 'Hepatite B', descricao: 'Previne hepatite B', dose: '3 doses');
      final vacina2 = VacinaModel(nome: 'Pneumocócica 23V', descricao: '...', dose: '...');

      final calendario = VacinasCalendarioModel(
        criancas: [],
        adolescentes: [],
        adultos: [],
        gestantes: [],
        idosos: [vacina1, vacina2],
      );

      // Aplica o filtro
      final resultado = calendario.selecionarLista('idoso_60_mais');

      expect(resultado.length, 2);
      final nomes = resultado.map((v) => v.nome).toList();
      expect(nomes, containsAll(['Hepatite B', 'Pneumocócica 23V']));
    });

    test('Selecting inexistent group', () {
      final vacina1 = VacinaModel(nome: 'Hepatite B', descricao: 'Previne hepatite B', dose: '3 doses');
      final vacina2 = VacinaModel(nome: 'BCG', descricao: 'Previne formas graves de tuberculose', dose: 'Dose única');

      final calendario = VacinasCalendarioModel(
        criancas: [vacina1, vacina2],
        adolescentes: [], adultos: [], gestantes: [], idosos: []
      );

      // Se passar uma chave inexistente ou vazia, retorna "criança" por padrão
      final resultado = calendario.selecionarLista('');

      expect(resultado.first.nome, 'Hepatite B');
      expect(resultado.length, 2);
    });
  });
}
