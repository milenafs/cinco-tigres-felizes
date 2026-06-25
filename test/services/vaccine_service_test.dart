import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Como o novo Service usa SharedPreferences para salvar as doses, 
    // precisamos simular uma memória vazia para o ambiente de testes não quebrar.
    SharedPreferences.setMockInitialValues({});
  });

  group('VacinasService', () {
    test('loads vaccines from bundled json asset', () async {
      final service = VacinasService();

      // Aguardamos o carregamento explícito do JSON
      await service.carregarVacinasJson();

      // Agora verificamos a propriedade 'calendario' que fica salva dentro do Service
      expect(service.calendario, isNotNull);
      expect(service.calendario!.criancas, isNotEmpty);
      expect(service.calendario!.criancas.first.nome, isNotEmpty);
    });
  });
}