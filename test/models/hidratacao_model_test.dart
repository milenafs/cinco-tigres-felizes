import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/models/hidratacao_model.dart';

void main() {
  group('Teste do HidratacaoModel', () {
    test('Deve calcular a porcentagem corretamente', () {
      final model = HidratacaoModel(metaDiaria: 2000, consumoAtual: 500);
      expect(model.porcentagem, 0.25); // 500/2000 = 0.25
    });

    test('Não deve ultrapassar 100% de progresso (clamp)', () {
      final model = HidratacaoModel(metaDiaria: 2000, consumoAtual: 3000);
      expect(model.porcentagem, 1.0);
    });

    test('Deve calcular o restante corretamente', () {
      final model = HidratacaoModel(metaDiaria: 2000, consumoAtual: 1200);
      expect(model.restante, 800);
    });

    test('Restante não deve ser negativo se passar da meta', () {
      final model = HidratacaoModel(metaDiaria: 2000, consumoAtual: 2500);
      expect(model.restante, 0);
    });
  });
}
