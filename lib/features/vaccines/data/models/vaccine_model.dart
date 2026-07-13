import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';

/// Tradutor: sabe ler JSON e entrega uma [Vacina] limpa para o resto do app.
class VacinaModel extends Vacina {
  VacinaModel({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.doseTexto,
    required super.quantidadeDeDoses,
  });

  factory VacinaModel.fromJson(Map<String, dynamic> json, String id) {
    return VacinaModel(
      id: id,
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
    // 1. Criamos um mapa que traduz o Enum diretamente para as chaves do JSON logo na entrada
    final mapeamentoJson = {
      CategoriaVacina.crianca: 'crianca_0_10',
      CategoriaVacina.adolescente: 'adolescente_11_19',
      CategoriaVacina.adulto: 'adulto_20_59',
      CategoriaVacina.gestante: 'gestante',
      CategoriaVacina.idoso: 'idoso_60_mais',
    };

    // 2. O parser agora recebe o Enum em vez da String
    List<Vacina> parseLista(CategoriaVacina categoria) {
      final chaveTexto = mapeamentoJson[categoria]!;
      final lista = json[chaveTexto] as List<dynamic>? ?? [];

      return lista.map((item) {
        final jsonMap = item as Map<String, dynamic>;
        final nomeVacina = jsonMap['nome'] as String? ?? '';
        return VacinaModel.fromJson(jsonMap, '${chaveTexto}_$nomeVacina');
      }).toList();
    }

    return CalendarioVacinasModel(
      criancas: parseLista(CategoriaVacina.crianca),
      adolescentes: parseLista(CategoriaVacina.adolescente),
      adultos: parseLista(CategoriaVacina.adulto),
      gestantes: parseLista(CategoriaVacina.gestante),
      idosos: parseLista(CategoriaVacina.idoso),
    );
  }
}
