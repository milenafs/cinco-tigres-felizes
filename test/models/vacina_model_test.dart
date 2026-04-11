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
}
