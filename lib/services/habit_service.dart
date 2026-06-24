import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit_model.dart';

class HabitoService {
  static const String _habitosKey = 'habitos_lista';

  Future<List<HabitoModel>> carregarHabitos() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_habitosKey);
    if (stored == null || stored.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(stored);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .map((item) => HabitoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> salvarHabitos(List<HabitoModel> habitos) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(habitos.map((h) => h.toJson()).toList());
    await prefs.setString(_habitosKey, encoded);
  }

  Future<void> adicionarHabito(HabitoModel habito) async {
    final habitos = await carregarHabitos();
    habitos.insert(0, habito);
    await salvarHabitos(habitos);
  }

  Future<void> atualizarHabito(HabitoModel habito) async {
    final habitos = await carregarHabitos();
    final index = habitos.indexWhere((item) => item.id == habito.id);
    if (index == -1) {
      habitos.insert(0, habito);
    } else {
      habitos[index] = habito;
    }
    await salvarHabitos(habitos);
  }

  Future<void> alternarConclusao(String habitoId, DateTime data) async {
    final habitos = await carregarHabitos();
    final index = habitos.indexWhere((item) => item.id == habitoId);
    if (index == -1) {
      return;
    }
    final atualizado = habitos[index].alternarConclusao(data);
    habitos[index] = atualizado;
    await salvarHabitos(habitos);
  }
}
