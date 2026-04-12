class LembreteAguaModel {
  final int id;
  final int frequenciaEmMinutos;
  final int horaInicio; // 0–23
  final int horaFim;    // 0–23

  LembreteAguaModel({
    required this.id,
    required this.frequenciaEmMinutos,
    required this.horaInicio,
    required this.horaFim,
  });

  List<DateTime> gerarHorariosParaHoje() {
    final agora = DateTime.now();

    final inicio = DateTime(
      agora.year,
      agora.month,
      agora.day,
      horaInicio,
    );

    final fim = DateTime(
      agora.year,
      agora.month,
      agora.day,
      horaFim,
    );

    List<DateTime> horarios = [];

    DateTime atual = inicio;

    while (atual.isBefore(fim) || atual.isAtSameMomentAs(fim)) {
      horarios.add(atual);
      atual = atual.add(Duration(minutes: frequenciaEmMinutos));
    }

    return horarios;
  }
  
  @override
  String toString() {
    return 'Inicio: $horaInicio, Fim: $horaFim, Frequência: $frequenciaEmMinutos min';
  }
}
