class HidratacaoModel {
  final int metaDiaria; // em ml
  final int consumoAtual; // em ml

  HidratacaoModel({required this.metaDiaria, required this.consumoAtual});

  // Calcula a porcentagem para o LinearProgressIndicator (entre 0.0 e 1.0)
  double get porcentagem {
    if (metaDiaria <= 0) return 0.0;
    double progresso = consumoAtual / metaDiaria;
    return progresso > 1.0 ? 1.0 : progresso;
  }

  // Retorna quanto falta para bater a meta
  int get restante =>
      (metaDiaria - consumoAtual) < 0 ? 0 : (metaDiaria - consumoAtual);

  // Converte para JSON
  Map<String, dynamic> toJson() {
    return {'metaDiaria': metaDiaria, 'consumoAtual': consumoAtual};
  }
}
