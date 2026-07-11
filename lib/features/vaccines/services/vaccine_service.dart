import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';

class VacinasService extends ChangeNotifier {
  final IVacinasRepository _repository;

  CalendarioVacinas? _calendario;
  Map<String, List<bool>> _dosesPorVacina = {};

  CalendarioVacinas? get calendario => _calendario;

  VacinasService(this._repository) {
    inicializar();
  }

  Future<void> inicializar() async {
    _calendario = await _repository.carregarCalendario();
    _dosesPorVacina = await _repository.carregarDoses();
    notifyListeners();
  }

  List<bool> obterStatusDoses(Vacina vacina) {
    final dosesSalvas = _dosesPorVacina[vacina.nome];

    if (dosesSalvas == null) {
      _dosesPorVacina[vacina.nome] = List.filled(vacina.quantidadeDeDoses, false);
    } 
    else if (dosesSalvas.length != vacina.quantidadeDeDoses) {
      List<bool> novaLista = List.filled(vacina.quantidadeDeDoses, false);
      
      for (int i = 0; i < novaLista.length && i < dosesSalvas.length; i++) {
        novaLista[i] = dosesSalvas[i];
      }
      
      _dosesPorVacina[vacina.nome] = novaLista;
    }

    return _dosesPorVacina[vacina.nome]!;
  }
  bool isVacinaCompleta(Vacina vacina) =>
      obterStatusDoses(vacina).every((tomada) => tomada);

  bool isVacinaEmProgresso(Vacina vacina) {
    final status = obterStatusDoses(vacina);
    return status.any((tomada) => tomada) && !isVacinaCompleta(vacina);
  }

  void alternarDose(Vacina vacina, int indexDose, bool tomada) {
    final status = obterStatusDoses(vacina);
    status[indexDose] = tomada;
    _dosesPorVacina[vacina.nome] = status;
    _repository.salvarDoses(_dosesPorVacina);
    notifyListeners();
  }

  List<Vacina> obterTodasAsVacinasUnicas() {
    if (_calendario == null) return [];

    final vacinasUnicas = <String, Vacina>{};
    final todasAsVacinas = [
      ..._calendario!.criancas,
      ..._calendario!.adolescentes,
      ..._calendario!.adultos,
      ..._calendario!.gestantes,
      ..._calendario!.idosos,
    ];

    for (final vacina in todasAsVacinas) {
      vacinasUnicas.putIfAbsent(vacina.nome, () => vacina);
    }

    return vacinasUnicas.values.toList();
  }

  List<Vacina> obterVacinasConcluidas() {
    final unicas = obterTodasAsVacinasUnicas();
    return unicas.where((v) => isVacinaCompleta(v)).toList();
  }
}
