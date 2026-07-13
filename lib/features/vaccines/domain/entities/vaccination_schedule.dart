enum CategoriaVacina { crianca, adolescente, adulto, gestante, idoso }

class Vacina {
  final String id;
  final String nome;
  final String descricao;
  final String doseTexto;
  final int quantidadeDeDoses;

  Vacina({
    required this.id,
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

  List<Vacina> selecionarLista(CategoriaVacina categoria) {
    switch (categoria) {
      case CategoriaVacina.adolescente:
        return adolescentes;
      case CategoriaVacina.adulto:
        return adultos;
      case CategoriaVacina.gestante:
        return gestantes;
      case CategoriaVacina.idoso:
        return idosos;
      case CategoriaVacina.crianca:
        return criancas;
    }
  }
}
