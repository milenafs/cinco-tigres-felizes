import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:cinco_tigres_felizes/features/vaccines/models/vaccine_model.dart';

class VacinasService {
  static const String _vacinasAssetPath = 'lib/features/vaccines/assets/vacinas.json';

  Future<VacinasCalendarioModel> carregarVacinas() async {
    final jsonString = await rootBundle.loadString(_vacinasAssetPath);
    final Map<String, dynamic> jsonMap =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return VacinasCalendarioModel.fromJson(jsonMap);
  }
}
