import 'dart:convert';

enum TipoFrequenciaHabito { diario, vezesPorDia }

const Map<TipoFrequenciaHabito, String> _rotulosFrequencia = {
  TipoFrequenciaHabito.diario: 'Diário',
  TipoFrequenciaHabito.vezesPorDia: 'X vezes por dia',
};

String rotuloFrequencia(TipoFrequenciaHabito tipo) => _rotulosFrequencia[tipo]!;

class HabitoModel {
  final String id;
  final String nome;
  final TipoFrequenciaHabito tipo;
  final int vezesPorDia;
  final Map<String, int> historico;

  HabitoModel({
    required this.id,
    required this.nome,
    required this.tipo,
    this.vezesPorDia = 1,
    this.historico = const {},
  });

  factory HabitoModel.fromJson(Map<String, dynamic> json) {
    final tipoIndex = json['tipo'] is int ? json['tipo'] as int : 0;
    final historicoRaw = json['historico'];

    Map<String, int> novoHistorico = {};
    if (historicoRaw is List) {
      for (final item in historicoRaw) {
        if (item is String) {
          novoHistorico[item] = 1;
        }
      }
    } else if (historicoRaw is Map) {
      novoHistorico = Map<String, int>.from(
        historicoRaw.map((k, v) => MapEntry(k.toString(), v is int ? v : 1)),
      );
    }

    return HabitoModel(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nome: json['nome'] as String? ?? '',
      tipo: TipoFrequenciaHabito
          .values[tipoIndex.clamp(0, TipoFrequenciaHabito.values.length - 1)],
      vezesPorDia: json['vezesPorDia'] is int ? json['vezesPorDia'] as int : 1,
      historico: novoHistorico,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo.index,
      'vezesPorDia': vezesPorDia,
      'historico': historico,
    };
  }

  HabitoModel copyWith({
    String? id,
    String? nome,
    TipoFrequenciaHabito? tipo,
    int? vezesPorDia,
    Map<String, int>? historico,
  }) {
    return HabitoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      vezesPorDia: vezesPorDia ?? this.vezesPorDia,
      historico: historico ?? Map<String, int>.from(this.historico),
    );
  }

  int obterContagem(DateTime data) {
    return historico[_chaveData(data)] ?? 0;
  }

  bool estaConcluidoEm(DateTime data) {
    return obterContagem(data) > 0;
  }

  HabitoModel alternarConclusao(DateTime data) {
    final chave = _chaveData(data);
    final atual = Map<String, int>.from(historico);

    switch (tipo) {
      case TipoFrequenciaHabito.diario:
        if (atual[chave] == null || atual[chave] == 0) {
          atual[chave] = 1;
        } else {
          atual.remove(chave);
        }
        break;
      case TipoFrequenciaHabito.vezesPorDia:
        final contagem = atual[chave] ?? 0;
        if (contagem < vezesPorDia) {
          atual[chave] = contagem + 1;
        } else {
          atual.remove(chave);
        }
        break;
    }

    return copyWith(historico: atual);
  }

  List<PeriodoHistorico> obterPeriodosHistorico() {
    return _periodoDiario();
  }

  List<PeriodoHistorico> _periodoDiario() {
    final hoje = DateTime.now();
    final periodos = <PeriodoHistorico>[];

    for (int i = 6; i >= 0; i--) {
      final data = DateTime(
        hoje.year,
        hoje.month,
        hoje.day,
      ).subtract(Duration(days: i));
      final contagem = obterContagem(data);
      periodos.add(
        PeriodoHistorico(
          data: data,
          label: '${data.day}',
          contagem: contagem,
          total: tipo == TipoFrequenciaHabito.vezesPorDia ? vezesPorDia : 1,
        ),
      );
    }

    return periodos;
  }

  String get frequenciaTexto {
    final label = rotuloFrequencia(tipo);
    if (tipo == TipoFrequenciaHabito.vezesPorDia) {
      return '$label: $vezesPorDia vezes';
    }
    return label;
  }

  String paraJsonString() => jsonEncode(toJson());

  static String _chaveData(DateTime data) {
    final normalizado = DateTime(data.year, data.month, data.day);
    return normalizado.toIso8601String().split('T').first;
  }
}

class PeriodoHistorico {
  final DateTime data;
  final String label;
  final int contagem;
  final int total;
  final bool podeMarcar;

  PeriodoHistorico({
    required this.data,
    required this.label,
    required this.contagem,
    required this.total,
    this.podeMarcar = true,
  });

  double get percentual => total == 0 ? 0 : (contagem / total).clamp(0, 1);

  bool get estaConcluido => contagem > 0;
}
