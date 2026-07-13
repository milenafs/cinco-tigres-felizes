import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';
import '../helpers/fake_vaccines_repository.dart';

void main() {
  group('VacinasService - Lógica de Status (Tabela de Decisão)', () {
    /* 
     * TÉCNICA APLICADA: Tabela de Decisão (Grafo Causa-Efeito)
     * Regras para uma vacina de 2 doses:
     * C1 (Dose 1) | C2 (Dose 2) || Em Progresso? | Completa?
     * ------------------------------------------------------
     * F           | F           || F             | F
     * V           | F           || V             | F
     * F           | V           || V             | F
     * V           | V           || F             | V
     */

    late VacinasService service;
    late FakeVacinasRepository repository;

    setUp(() async {
      repository = FakeVacinasRepository(
        calendario: FakeVacinasRepository.calendario(
          criancas: [FakeVacinasRepository.vacina('HPV', doses: 2)],
        ),
      );
      service = VacinasService(repository);
      await service.inicializar();
    });

    test('Regra 1: [Falso, Falso] -> Progresso: Falso, Completa: Falso', () {
      final vacina = service.calendario!.criancas.first;

      expect(service.isVacinaEmProgresso(vacina), isFalse);
      expect(service.isVacinaCompleta(vacina), isFalse);
    });

    test(
      'Regra 2: [Verdadeiro, Falso] -> Progresso: Verdadeiro, Completa: Falso',
      () {
        final vacina = service.calendario!.criancas.first;
        service.alternarDose(vacina, 0, true); // Toma a dose 1

        expect(service.isVacinaEmProgresso(vacina), isTrue);
        expect(service.isVacinaCompleta(vacina), isFalse);
      },
    );

    test(
      'Regra 3: [Verdadeiro, Verdadeiro] -> Progresso: Falso, Completa: Verdadeiro',
      () {
        final vacina = service.calendario!.criancas.first;
        service.alternarDose(vacina, 0, true); // Toma a dose 1
        service.alternarDose(vacina, 1, true); // Toma a dose 2

        expect(service.isVacinaEmProgresso(vacina), isFalse);
        expect(service.isVacinaCompleta(vacina), isTrue);
      },
    );
  });
}
