import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/models/lembrete_agua_model.dart';

void main() {
  group('LembreteAguaServices', () {
    test('cria lembrete com dados válidos', () {
      final lembrete = LembreteAguaModel(
        id: DateTime.now().millisecondsSinceEpoch,
        frequenciaEmMinutos: 60,
        horaInicio: 8,
        minutoInicio: 0, // Novo parâmetro
        horaFim: 22,
        minutoFim: 0,    // Novo parâmetro
      );

      expect(lembrete.id, isNotNull);
      expect(lembrete.frequenciaEmMinutos, 60);
      expect(lembrete.horaInicio, 8);
      expect(lembrete.minutoInicio, 0);
      expect(lembrete.horaFim, 22);
      expect(lembrete.minutoFim, 0);
    });

    test('validação de frequência mínima', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 1,
        horaInicio: 8,
        minutoInicio: 0,
        horaFim: 22,
        minutoFim: 0,
      );

      expect(lembrete.frequenciaEmMinutos, greaterThan(0));
    });

    test('validação de intervalo de horas', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 60,
        horaInicio: 0,
        minutoInicio: 0,
        horaFim: 23,
        minutoFim: 59,
      );

      expect(lembrete.horaInicio, greaterThanOrEqualTo(0));
      expect(lembrete.horaFim, lessThanOrEqualTo(23));
      expect(lembrete.minutoFim, lessThanOrEqualTo(59));
    });

    test('calcula corretamente a quantidade de lembretes por dia', () {
      // Exemplo: 08:30 até 10:30 (120 minutos de intervalo)
      // Frequência de 60 min -> 08:30, 09:30, 10:30 (3 lembretes)
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 60,
        horaInicio: 8,
        minutoInicio: 30,
        horaFim: 10,
        minutoFim: 30,
      );

      final horarios = lembrete.gerarHorariosParaHoje();
      
      // Cálculo manual para validação:
      // Intervalo = (10*60 + 30) - (8*60 + 30) = 630 - 510 = 120 min
      // Quantidade = (120 / 60) + 1 = 3
      final intervaloEmMinutos = 
          ((lembrete.horaFim * 60) + lembrete.minutoFim) - 
          ((lembrete.horaInicio * 60) + lembrete.minutoInicio);
      
      final expected = (intervaloEmMinutos ~/ lembrete.frequenciaEmMinutos) + 1;

      expect(horarios.length, expected);
      expect(horarios.length, 3);
    });
  });
}