import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/models/lembrete_agua_model.dart';

void main() {
  group('LembreteAguaServices', () {
    test('cria lembrete com dados válidos', () {
      final lembrete = LembreteAguaModel(
        id: DateTime.now().millisecondsSinceEpoch,
        frequenciaEmMinutos: 60,
        horaInicio: 8,
        horaFim: 22,
      );

      expect(lembrete.id, isNotNull);
      expect(lembrete.frequenciaEmMinutos, 60);
      expect(lembrete.horaInicio, 8);
      expect(lembrete.horaFim, 22);
    });

    test('validação de frequência mínima', () {
      // Frequência mínima deve ser maior que 0
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 1,
        horaInicio: 8,
        horaFim: 22,
      );

      expect(lembrete.frequenciaEmMinutos, greaterThan(0));
    });

    test('validação de intervalo de horas', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 60,
        horaInicio: 0,
        horaFim: 23,
      );

      expect(lembrete.horaInicio, greaterThanOrEqualTo(0));
      expect(lembrete.horaFim, lessThanOrEqualTo(23));
    });

    test('calcula corretamente a quantidade de lembretes por dia', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 120, // 2 horas
        horaInicio: 8,
        horaFim: 20,
      );

      final horarios = lembrete.gerarHorariosParaHoje();
      final intervalo = (20 - 8) * 60; // 12 horas = 720 minutos
      final expected = (intervalo ~/ 120) + 1; // quantidade esperada

      expect(horarios.length, expected);
    });
  });
}
