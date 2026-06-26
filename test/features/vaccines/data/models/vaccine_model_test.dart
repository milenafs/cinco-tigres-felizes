import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/vaccines/data/models/vaccine_model.dart';

void main() {
  group('VacinaModel', () {
    test('fromJson mapeia todos os campos corretamente', () {
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
    });

    test('fromJson aceita quantidade_doses como String', () {
      final json = {
        'nome': 'Hepatite B',
        'descricao': 'Previne hepatite B',
        'dose_texto': '3 doses',
        'quantidade_doses': '3', // o JSON real vem como String
      };

      final model = VacinaModel.fromJson(json);

      expect(model.quantidadeDeDoses, 3);
    });
  });

  group('CalendarioVacinasModel', () {
    test('fromJson parseia todos os grupos corretamente', () {
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

      final calendario = CalendarioVacinasModel.fromJson(json);

      expect(calendario.criancas.length, 1);
      expect(calendario.criancas.first.nome, 'BCG');
      expect(calendario.gestantes.length, 1);
      expect(calendario.gestantes.first.nome, 'dTPa');
      expect(calendario.adolescentes, isEmpty);
      expect(calendario.adultos, isEmpty);
      expect(calendario.idosos, isEmpty);
    });

    test('fromJson com grupo ausente no JSON retorna lista vazia', () {
      // Garante robustez caso o JSON evolua e adicione novos grupos
      final json = {
        'crianca_0_10': <Map<String, dynamic>>[],
        'adolescente_11_19': <Map<String, dynamic>>[],
        'adulto_20_59': <Map<String, dynamic>>[],
        'gestante': <Map<String, dynamic>>[],
        'idoso_60_mais': <Map<String, dynamic>>[],
      };

      final calendario = CalendarioVacinasModel.fromJson(json);

      expect(calendario.criancas, isEmpty);
      expect(calendario.idosos, isEmpty);
    });
  });
}
