import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';

class VacinasService extends ChangeNotifier {
  final IVacinasRepository _repository;

  CalendarioVacinas? calendario;
  Map<String, List<bool>> _dosesPorVacina = {};

  VacinasService(this._repository) {
    inicializar();
  }

  Future<void> inicializar() async {
    calendario = await _repository.carregarCalendario();
    _dosesPorVacina = await _repository.carregarDoses();
    notifyListeners();
  }

  List<bool> obterStatusDoses(Vacina vacina) {
    if (_dosesPorVacina[vacina.nome]?.length != vacina.quantidadeDeDoses) {
      _dosesPorVacina[vacina.nome] = List.filled(vacina.quantidadeDeDoses, false);
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
}
