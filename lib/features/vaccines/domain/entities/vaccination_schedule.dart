class Vacina {
  final String nome;
  final String descricao;
  final String doseTexto;
  final int quantidadeDeDoses;

  Vacina({
    required this.nome,
    required this.descricao,
    required this.doseTexto,
    required this.quantidadeDeDoses,
  });
}

class CalendarioVacinas {
  final List<Vacina> criancas;
  final List<Vacina> adolescentes;
  final List<Vacina> adultos;
  final List<Vacina> gestantes;
  final List<Vacina> idosos;

  CalendarioVacinas({
    required this.criancas,
    required this.adolescentes,
    required this.adultos,
    required this.gestantes,
    required this.idosos,
  });

  List<Vacina> selecionarLista(String categoria) {
    switch (categoria) {
      case 'adolescente_11_19': return adolescentes;
      case 'adulto_20_59':      return adultos;
      case 'gestante':          return gestantes;
      case 'idoso_60_mais':     return idosos;
      default:                  return criancas;
    }
  }
}
