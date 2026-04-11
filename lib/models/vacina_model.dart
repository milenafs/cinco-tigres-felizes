class VacinaModel {
  final String nome;
  final String descricao;
  final String dose;

  VacinaModel({
    required this.nome,
    required this.descricao,
    required this.dose,
  });

  factory VacinaModel.fromJson(Map<String, dynamic> json) {
    return VacinaModel(
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      dose: json['dose'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nome': nome, 'descricao': descricao, 'dose': dose};
  }
}

class VacinasCalendarioModel {
  final List<VacinaModel> criancas;
  final List<VacinaModel> adolescentes;
  final List<VacinaModel> adultos;
  final List<VacinaModel> gestantes;
  final List<VacinaModel> idosos;

  VacinasCalendarioModel({
    required this.criancas,
    required this.adolescentes,
    required this.adultos,
    required this.gestantes,
    required this.idosos,
  });

  factory VacinasCalendarioModel.fromJson(Map<String, dynamic> json) {
    List<VacinaModel> parseLista(String chave) {
      final lista = (json[chave] as List<dynamic>? ?? <dynamic>[]);
      return lista
          .map((item) => VacinaModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return VacinasCalendarioModel(
      criancas: parseLista('crianca_0_10'),
      adolescentes: parseLista('adolescente_11_19'),
      adultos: parseLista('adulto_20_59'),
      gestantes: (json['gestante'] != null)
          ? parseLista('gestante')
          : parseLista('gestantes'),
      idosos: parseLista('idoso_60_mais'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crianca_0_10': criancas.map((vacina) => vacina.toJson()).toList(),
      'adolescente_11_19': adolescentes
          .map((vacina) => vacina.toJson())
          .toList(),
      'adulto_20_59': adultos.map((vacina) => vacina.toJson()).toList(),
      'gestantes': gestantes.map((vacina) => vacina.toJson()).toList(),
      'idoso_60_mais': idosos.map((vacina) => vacina.toJson()).toList(),
    };
  }
}
