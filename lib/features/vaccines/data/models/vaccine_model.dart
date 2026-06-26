import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';

/// Tradutor: sabe ler JSON e entrega uma [Vacina] limpa para o resto do app.
class VacinaModel extends Vacina {
  VacinaModel({
    required super.nome,
    required super.descricao,
    required super.doseTexto,
    required super.quantidadeDeDoses,
  });

  factory VacinaModel.fromJson(Map<String, dynamic> json) {
    return VacinaModel(
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      doseTexto: json['dose_texto'] as String,
      quantidadeDeDoses: int.parse(json['quantidade_doses'].toString()),
    );
  }
}

/// Tradutor do calendário completo.
class CalendarioVacinasModel extends CalendarioVacinas {
  CalendarioVacinasModel({
    required super.criancas,
    required super.adolescentes,
    required super.adultos,
    required super.gestantes,
    required super.idosos,
  });

  factory CalendarioVacinasModel.fromJson(Map<String, dynamic> json) {
    List<Vacina> parseLista(String chave) {
      final lista = json[chave] as List<dynamic>? ?? [];
      return lista
          .map((item) => VacinaModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return CalendarioVacinasModel(
      criancas:     parseLista('crianca_0_10'),
      adolescentes: parseLista('adolescente_11_19'),
      adultos:      parseLista('adulto_20_59'),
      gestantes:    parseLista('gestante'),
      idosos:       parseLista('idoso_60_mais'),
    );
  }
}
