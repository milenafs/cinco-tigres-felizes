import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/models/lembrete_agua_model.dart';

void main() {
  group('LembreteAguaModel', () {
    test('cria modelo com valores corretos', () {
      final lembrete = LembreteAguaModel(
        id: 123,
        frequenciaEmMinutos: 30,
        horaInicio: 8,
        minutoInicio: 15,
        horaFim: 22,
        minutoFim: 45,   
      );

      expect(lembrete.id, 123);
      expect(lembrete.frequenciaEmMinutos, 30);
      expect(lembrete.horaInicio, 8);
      expect(lembrete.minutoInicio, 15);
      expect(lembrete.horaFim, 22);
      expect(lembrete.minutoFim, 45);
    });

    test('gera horários corretamente para o dia', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 60,
        horaInicio: 8,
        minutoInicio: 0,
        horaFim: 10,
        minutoFim: 0,
      );

      final horarios = lembrete.gerarHorariosParaHoje();

      expect(horarios.length, 3); // 08:00, 09:00, 10:00
      expect(horarios[0].hour, 8);
      expect(horarios[1].hour, 9);
      expect(horarios[2].hour, 10);
    });

    test('gera horários respeitando os minutos de início', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 30,
        horaInicio: 8,
        minutoInicio: 30, // Início às 08:30
        horaFim: 9,
        minutoFim: 30,    // Fim às 09:30
      );

      final horarios = lembrete.gerarHorariosParaHoje();

      // Esperado: 08:30, 09:00, 09:30
      expect(horarios.length, 3);
      expect(horarios[0].minute, 30);
      expect(horarios[1].minute, 0);
      expect(horarios[2].minute, 30);
    });

    test('toString retorna formato esperado com minutos', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 30,
        horaInicio: 8,
        minutoInicio: 0,
        horaFim: 22,
        minutoFim: 0,
      );

      final resultado = lembrete.toString();

      // Ajuste para bater com o toString que sugerimos (Início: 8:00...)
      expect(resultado, "Inicio: 8, Fim: 22, Frequência: 30 min");
    });
  });
}