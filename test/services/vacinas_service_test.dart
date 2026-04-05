import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/services/vacinas_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VacinasService', () {
    test('loads vaccines from bundled json asset', () async {
      final service = VacinasService();

      final calendario = await service.carregarVacinas();

      expect(calendario.criancas, isNotEmpty);
      expect(calendario.criancas.first.nome, isNotEmpty);
    });
  });
}
