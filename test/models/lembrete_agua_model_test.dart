import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/models/lembrete_agua_model.dart';

void main() {
  group('LembreteAguaModel', () {
    test('cria modelo com valores corretos', () {
      final lembrete = LembreteAguaModel(
        id: 123,
        frequenciaEmMinutos: 30,
        horaInicio: 8,
        horaFim: 22,
      );

      expect(lembrete.id, 123);
      expect(lembrete.frequenciaEmMinutos, 30);
      expect(lembrete.horaInicio, 8);
      expect(lembrete.horaFim, 22);
    });

    test('gera horários corretamente para o dia', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 60,
        horaInicio: 8,
        horaFim: 10,
      );

      final horarios = lembrete.gerarHorariosParaHoje();

      expect(horarios.length, 3); // 8:00, 9:00, 10:00
      expect(horarios[0].hour, 8);
      expect(horarios[1].hour, 9);
      expect(horarios[2].hour, 10);
    });

    test('gera horários com frequência em minutos', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 30,
        horaInicio: 8,
        horaFim: 9,
      );

      final horarios = lembrete.gerarHorariosParaHoje();

      expect(horarios.length, 3); // 8:00, 8:30, 9:00
      expect(horarios[0].minute, 0);
      expect(horarios[1].minute, 30);
      expect(horarios[2].minute, 0);
    });

    test('gera horários com intervalo pequeno', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 15,
        horaInicio: 8,
        horaFim: 8,
      );

      final horarios = lembrete.gerarHorariosParaHoje();

      expect(horarios.length, 1); // apenas 8:00
      expect(horarios[0].hour, 8);
      expect(horarios[0].minute, 0);
    });

    test('horários respeitam o intervalo definido', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 120,
        horaInicio: 6,
        horaFim: 18,
      );

      final horarios = lembrete.gerarHorariosParaHoje();

      // 6:00, 8:00, 10:00, 12:00, 14:00, 16:00, 18:00
      expect(horarios.length, 7);
      expect(horarios.first.hour, 6);
      expect(horarios.last.hour, 18);

      for (int i = 1; i < horarios.length; i++) {
        final diferenca = horarios[i].difference(horarios[i - 1]);
        expect(diferenca.inMinutes, 120);
      }
    });

    test('toString retorna formato esperado', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 30,
        horaInicio: 8,
        horaFim: 22,
      );

      final resultado = lembrete.toString();

      expect(resultado, "Inicio: 8, Fim: 22, Frequência: 30 min");
    });

    test('frequência de 1 minuto não gera múltiplos horários', () {
      final lembrete = LembreteAguaModel(
        id: 1,
        frequenciaEmMinutos: 1,
        horaInicio: 8,
        horaFim: 8,
      );

      final horarios = lembrete.gerarHorariosParaHoje();

      expect(horarios.length, 1);
    });
  });
}
