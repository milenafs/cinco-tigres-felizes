import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/data/models/vaccine_model.dart';

class VacinasRepository implements IVacinasRepository {
  static const String _vacinasAssetPath = 'lib/features/vaccines/data/vaccine.json';
  static const String _storageKey = 'doses_tomadas';

  @override
  Future<CalendarioVacinas> carregarCalendario() async {
    final jsonString = await rootBundle.loadString(_vacinasAssetPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return CalendarioVacinasModel.fromJson(jsonMap); // devolve a entidade, não o model
  }

  @override
  Future<Map<String, List<bool>>> carregarDoses() async {
    final prefs = await SharedPreferences.getInstance();
    final dadosSalvos = prefs.getString(_storageKey);
    if (dadosSalvos == null) return {};
    final decoded = jsonDecode(dadosSalvos) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, List<bool>.from(value as List)));
  }

  @override
  Future<void> salvarDoses(Map<String, List<bool>> doses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(doses));
  }
}
