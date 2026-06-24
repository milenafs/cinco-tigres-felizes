import 'dart:convert';

enum TipoFrequenciaHabito {
  diario,
  diasDaSemana,
  vezesPorDia,
  semanal,
  mensal,
}

const Map<TipoFrequenciaHabito, String> _rotulosFrequencia = {
  TipoFrequenciaHabito.diario: 'Diário',
  TipoFrequenciaHabito.diasDaSemana: 'Dias da semana',
  TipoFrequenciaHabito.vezesPorDia: 'X vezes por dia',
  TipoFrequenciaHabito.semanal: 'Semanal',
  TipoFrequenciaHabito.mensal: 'Mensal',
};

const List<String> _rotulosDiasSemana = [
  'Seg',
  'Ter',
  'Qua',
  'Qui',
  'Sex',
  'Sáb',
  'Dom',
];

String rotuloFrequencia(TipoFrequenciaHabito tipo) => _rotulosFrequencia[tipo]!;
String rotuloDiaSemana(int index) => _rotulosDiasSemana[index - 1];

class HabitoModel {
  final String id;
  final String nome;
  final TipoFrequenciaHabito tipo;
  final int vezesPorDia;
  final List<int> diasDaSemana;
  final int? diaDoMes;
  final Map<String, int> historico;

  HabitoModel({
    required this.id,
    required this.nome,
    required this.tipo,
    this.vezesPorDia = 1,
    this.diasDaSemana = const [],
    this.diaDoMes,
    this.historico = const {},
  });

  factory HabitoModel.fromJson(Map<String, dynamic> json) {
    final tipoIndex = json['tipo'] is int ? json['tipo'] as int : 0;
    final listaDias = json['diasDaSemana'];
    final historicoRaw = json['historico'];

    // Converter histórico antigo (Set<String>) para novo (Map<String, int>)
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
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nome: json['nome'] as String? ?? '',
      tipo: TipoFrequenciaHabito.values[tipoIndex.clamp(0, TipoFrequenciaHabito.values.length - 1)],
      vezesPorDia: json['vezesPorDia'] is int ? json['vezesPorDia'] as int : 1,
      diasDaSemana: listaDias is List ? List<int>.from(listaDias.map((value) => value as int)) : [],
      diaDoMes: json['diaDoMes'] is int ? json['diaDoMes'] as int : null,
      historico: novoHistorico,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo.index,
      'vezesPorDia': vezesPorDia,
      'diasDaSemana': diasDaSemana,
      'diaDoMes': diaDoMes,
      'historico': historico,
    };
  }

  HabitoModel copyWith({
    String? id,
    String? nome,
    TipoFrequenciaHabito? tipo,
    int? vezesPorDia,
    List<int>? diasDaSemana,
    int? diaDoMes,
    Map<String, int>? historico,
  }) {
    return HabitoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      vezesPorDia: vezesPorDia ?? this.vezesPorDia,
      diasDaSemana: diasDaSemana ?? List<int>.from(this.diasDaSemana),
      diaDoMes: diaDoMes ?? this.diaDoMes,
      historico: historico ?? Map<String, int>.from(this.historico),
    );
  }

  // Retorna contagem de conclusões em uma data
  int obterContagem(DateTime data) {
    return historico[_chaveData(data)] ?? 0;
  }

  // Verifica se foi concluído em uma data (para diário)
  bool estaConcluidoEm(DateTime data) {
    return obterContagem(data) > 0;
  }

  // Alterna conclusão (incrementa/decrementa baseado no tipo)
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

      case TipoFrequenciaHabito.diasDaSemana:
      case TipoFrequenciaHabito.semanal:
      case TipoFrequenciaHabito.mensal:
        if (atual[chave] == null || atual[chave] == 0) {
          atual[chave] = 1;
        } else {
          atual.remove(chave);
        }
        break;
    }

    return copyWith(historico: atual);
  }

  // Retorna datas para exibição conforme o tipo
  List<PeriodoHistorico> obterPeriodosHistorico() {
    switch (tipo) {
      case TipoFrequenciaHabito.diario:
        return _periodoDiario();
      case TipoFrequenciaHabito.vezesPorDia:
        return _periodoDiario();
      case TipoFrequenciaHabito.diasDaSemana:
        return _periodoSemanal();
      case TipoFrequenciaHabito.semanal:
        return _periodoSemanal();
      case TipoFrequenciaHabito.mensal:
        return _periodoMensal();
    }
  }

  List<PeriodoHistorico> _periodoDiario() {
    final hoje = DateTime.now();
    final periodos = <PeriodoHistorico>[];

    for (int i = 6; i >= 0; i--) {
      final data = DateTime(hoje.year, hoje.month, hoje.day).subtract(Duration(days: i));
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

  List<PeriodoHistorico> _periodoSemanal() {
    final hoje = DateTime.now();
    final periodos = <PeriodoHistorico>[];

    for (int i = 6; i >= 0; i--) {
      final data = DateTime(hoje.year, hoje.month, hoje.day).subtract(Duration(days: i));
      final diaSemana = data.weekday;

      // Verifica se este dia está na lista de dias configurados
      final ehDiaConfigurable = diasDaSemana.contains(diaSemana == 7 ? 7 : diaSemana);

      final contagem = estaConcluidoEm(data) ? 1 : 0;
      periodos.add(
        PeriodoHistorico(
          data: data,
          label: rotuloDiaSemana(diaSemana == 7 ? 7 : diaSemana),
          contagem: contagem,
          total: ehDiaConfigurable ? 1 : 0,
          podeMarcar: ehDiaConfigurable,
        ),
      );
    }

    return periodos;
  }

  List<PeriodoHistorico> _periodoMensal() {
    final hoje = DateTime.now();
    final periodos = <PeriodoHistorico>[];

    for (int i = 11; i >= 0; i--) {
      final mes = DateTime(hoje.year, hoje.month - i, 1);
      final mesKey = '${mes.year}-${mes.month.toString().padLeft(2, '0')}';

      // Contar quantos dias no mês foram marcados
      int contagemMes = 0;
      for (final entrada in historico.entries) {
        if (entrada.key.startsWith(mesKey)) {
          contagemMes += (entrada.value > 0) ? 1 : 0;
        }
      }

      periodos.add(
        PeriodoHistorico(
          data: mes,
          label: '${mes.month}/${mes.year.toString().substring(2)}',
          contagem: contagemMes,
          total: DateTime(mes.year, mes.month + 1, 0).day,
        ),
      );
    }

    return periodos;
  }

  String get frequenciaTexto {
    final label = rotuloFrequencia(tipo);
    switch (tipo) {
      case TipoFrequenciaHabito.diasDaSemana:
        if (diasDaSemana.isEmpty) {
          return label;
        }
        final nomes = diasDaSemana.map(rotuloDiaSemana).join(', ');
        return '$label: $nomes';
      case TipoFrequenciaHabito.vezesPorDia:
        return '$label: $vezesPorDia vezes';
      case TipoFrequenciaHabito.mensal:
        if (diaDoMes != null) {
          return '$label: dia $diaDoMes';
        }
        return label;
      default:
        return label;
    }
  }

  String paraJsonString() => jsonEncode(toJson());

  static String _chaveData(DateTime data) {
    final normalizado = DateTime(data.year, data.month, data.day);
    return normalizado.toIso8601String().split('T').first;
  }
}

// Classe auxiliar para representar um período no histórico
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
