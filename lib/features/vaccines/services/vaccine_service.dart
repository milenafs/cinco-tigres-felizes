import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinco_tigres_felizes/features/vaccines/models/vaccine_model.dart';

class VacinasService extends ChangeNotifier {
  static const String _vacinasAssetPath = 'lib/features/vaccines/data/vaccine.json';
  static const String _storageKey = 'doses_tomadas';

  VacinasCalendarioModel? calendario;
  Map<String, List<bool>> _dosesPorVacina = {};

  VacinasService() {
    inicializar();
  }

  Future<void> inicializar() async {
    await carregarVacinasJson();
    await _carregarDoStorage();
    notifyListeners();
  }

  Future<void> carregarVacinasJson() async {
    final jsonString = await rootBundle.loadString(_vacinasAssetPath);
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    calendario = VacinasCalendarioModel.fromJson(jsonMap);
  }

  Future<void> _carregarDoStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dadosSalvos = prefs.getString(_storageKey);
    
    if (dadosSalvos != null) {
      final Map<String, dynamic> decoded = jsonDecode(dadosSalvos);
      _dosesPorVacina = decoded.map((key, value) => MapEntry(key, List<bool>.from(value)));
    }
  }

  Future<void> _salvarNoStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_dosesPorVacina);
    await prefs.setString(_storageKey, encoded);
  }

  List<bool> obterStatusDoses(VacinaModel vacina) {
    if (!_dosesPorVacina.containsKey(vacina.nome)) {
      _dosesPorVacina[vacina.nome] = List.filled(vacina.quantidadeDeDoses, false);
    }
    // Caso o JSON mude e diminua/aumente a quantidade de doses para um nome já salvo
    if (_dosesPorVacina[vacina.nome]!.length != vacina.quantidadeDeDoses) {
       _dosesPorVacina[vacina.nome] = List.filled(vacina.quantidadeDeDoses, false);
    }
    return _dosesPorVacina[vacina.nome]!;
  }

  void alternarDose(VacinaModel vacina, int indexDose, bool tomada) {
    final status = obterStatusDoses(vacina);
    status[indexDose] = tomada;
    _dosesPorVacina[vacina.nome] = status;
    _salvarNoStorage();
    notifyListeners();
  }

  bool isVacinaCompleta(VacinaModel vacina) {
    final status = obterStatusDoses(vacina);
    return status.every((doseTomada) => doseTomada == true);
  }

  //Verifica se o usuário já tomou alguma dose, mas não todas
  bool isVacinaEmProgresso(VacinaModel vacina) {
    final status = obterStatusDoses(vacina);
    final temDoseTomada = status.any((doseTomada) => doseTomada == true);
    final isCompleta = isVacinaCompleta(vacina);
    return temDoseTomada && !isCompleta;
  }
}