import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/vaccines/models/vaccine_model.dart';

void main() {
  group('VacinaModel', () {
    test('fromJson and toJson maps fields correctly', () {
      final json = {
        'nome': 'BCG',
        'descricao': 'Previne tuberculose',
        'dose_texto': 'Dose unica',
        'quantidade_doses': 1, 
      };

      final model = VacinaModel.fromJson(json);

      expect(model.nome, 'BCG');
      expect(model.descricao, 'Previne tuberculose');
      expect(model.doseTexto, 'Dose unica'); 
      expect(model.quantidadeDeDoses, 1);   
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
            'dose_texto': 'Dose unica',
            'quantidade_doses': 1,
          },
        ],
        'adolescente_11_19': <Map<String, dynamic>>[],
        'adulto_20_59': <Map<String, dynamic>>[],
        'gestante': [
          {
            'nome': 'dTPa',
            'descricao': 'Previne difteria, tetano e coqueluche',
            'dose_texto': '1 dose por gestacao',
            'quantidade_doses': 1,
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
      final vacinaG1 = VacinaModel(nome: 'Hepatite B', descricao: 'Previne hepatite B', doseTexto: '3 doses', quantidadeDeDoses: 3);
      final vacinaG2 = VacinaModel(nome: 'dTPa', descricao: 'Previne difteria, tétano e coqueluche', doseTexto: '1 dose por gestação', quantidadeDeDoses: 1);
      final vacinaC1 = VacinaModel(nome: 'BCG', descricao: 'Previne formas graves de tuberculose', doseTexto: 'Dose única', quantidadeDeDoses: 1);

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
      final vacinaC1 = VacinaModel(nome: 'Hepatite B', descricao: 'Previne hepatite B', doseTexto: '3 doses', quantidadeDeDoses: 3);
      final vacinaC2 = VacinaModel(nome: 'BCG', descricao: 'Previne formas graves de tuberculose', doseTexto: 'Dose única', quantidadeDeDoses: 1);
      final vacinaC3 = VacinaModel(nome: 'VIP (Poliomielite inativada)', descricao: 'Previne poliomielite', doseTexto: '1ª, 2ª e 3ª doses', quantidadeDeDoses: 3);

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
      final vacina1 = VacinaModel(nome: 'Hepatite B', descricao: 'Previne hepatite B', doseTexto: '3 doses', quantidadeDeDoses: 3);
      final vacina2 = VacinaModel(nome: 'Pneumocócica 23V', descricao: '...', doseTexto: '...', quantidadeDeDoses: 1);

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
      final vacina1 = VacinaModel(nome: 'Hepatite B', descricao: 'Previne hepatite B', doseTexto: '3 doses', quantidadeDeDoses: 3);
      final vacina2 = VacinaModel(nome: 'BCG', descricao: 'Previne formas graves de tuberculose', doseTexto: 'Dose única', quantidadeDeDoses: 1);

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