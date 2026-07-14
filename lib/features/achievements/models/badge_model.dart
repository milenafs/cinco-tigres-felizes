class BadgeModel {
  final String id;
  final String titulo;
  final String descricaoCondicao;
  final int metaDiasConsecutivos;
  final DateTime? desbloqueadoEm;
  final String iconePath;

  BadgeModel({
    required this.id,
    required this.titulo,
    required this.descricaoCondicao,
    required this.metaDiasConsecutivos,
    required this.iconePath,
    this.desbloqueadoEm,
  });

  bool get isDesbloqueado => desbloqueadoEm != null;

  BadgeModel copyWith({
    String? id,
    String? titulo,
    String? descricaoCondicao,
    int? metaDiasConsecutivos,
    String? iconePath,
    DateTime? desbloqueadoEm,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricaoCondicao: descricaoCondicao ?? this.descricaoCondicao,
      metaDiasConsecutivos: metaDiasConsecutivos ?? this.metaDiasConsecutivos,
      iconePath: iconePath ?? this.iconePath,
      desbloqueadoEm: desbloqueadoEm ?? this.desbloqueadoEm,
    );
  }
}