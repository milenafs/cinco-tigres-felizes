import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';
import '../helpers/fake_vaccines_repository.dart';

void main() {
  group('VacinasService', () {
    late Vacina bcg;
    late Vacina hepatiteB;
    late VacinasService service;

    setUp(() async {
      bcg = FakeVacinasRepository.vacina('BCG', doses: 1);
      hepatiteB = FakeVacinasRepository.vacina('Hepatite B', doses: 3);

      final repo = FakeVacinasRepository(
        calendario: FakeVacinasRepository.calendario(
          criancas: [bcg, hepatiteB],
        ),
      );

      service = VacinasService(repo);
      await service.inicializar();
    });

    group('inicialização', () {
      test('carrega o calendário do repositório', () {
        expect(service.calendario, isNotNull);
        expect(service.calendario!.criancas.length, 2);
        expect(service.calendario!.criancas.first.nome, 'BCG');
      });

      test('doses começam todas como não tomadas', () {
        expect(service.obterStatusDoses(bcg), everyElement(isFalse));
        expect(service.obterStatusDoses(bcg).length, 1);
      });
    });

    group('obterStatusDoses', () {
      test('retorna lista com tamanho igual a quantidadeDeDoses', () {
        expect(service.obterStatusDoses(hepatiteB).length, 3);
      });
    });

    group('isVacinaCompleta', () {
      test('retorna false enquanto há doses pendentes', () {
        expect(service.isVacinaCompleta(hepatiteB), isFalse);
      });

      test('retorna true quando todas as doses são tomadas', () {
        service.alternarDose(hepatiteB, 0, true);
        service.alternarDose(hepatiteB, 1, true);
        service.alternarDose(hepatiteB, 2, true);

        expect(service.isVacinaCompleta(hepatiteB), isTrue);
      });
    });

    group('isVacinaEmProgresso', () {
      test('retorna false quando nenhuma dose foi tomada', () {
        expect(service.isVacinaEmProgresso(hepatiteB), isFalse);
      });

      test('retorna true com progresso parcial', () {
        service.alternarDose(hepatiteB, 0, true);

        expect(service.isVacinaEmProgresso(hepatiteB), isTrue);
        expect(service.isVacinaCompleta(hepatiteB), isFalse);
      });

      test('retorna false quando vacina está completa', () {
        service.alternarDose(hepatiteB, 0, true);
        service.alternarDose(hepatiteB, 1, true);
        service.alternarDose(hepatiteB, 2, true);

        expect(service.isVacinaEmProgresso(hepatiteB), isFalse);
      });
    });

    group('alternarDose', () {
      test('marca uma dose como tomada', () {
        service.alternarDose(bcg, 0, true);

        expect(service.isVacinaCompleta(bcg), isTrue);
      });

      test('desmarca uma dose já tomada', () {
        service.alternarDose(bcg, 0, true);
        service.alternarDose(bcg, 0, false);

        expect(service.isVacinaCompleta(bcg), isFalse);
      });
    });
  });
}
