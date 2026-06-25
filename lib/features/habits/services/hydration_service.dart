import 'package:flutter/material.dart';
import '../models/hydration_model.dart';

class HidratacaoService extends ChangeNotifier {
  int _consumoAtual = 0;
  int _metaDiaria = 2000; 

  HidratacaoModel get model => HidratacaoModel(
        metaDiaria: _metaDiaria,
        consumoAtual: _consumoAtual,
      );

  void adicionarAgua(int quantidade) {
    _consumoAtual += quantidade;
    notifyListeners();
  }

  void zerarDia() {
    _consumoAtual = 0;
    notifyListeners();
  }

  // Atualiza a meta diária e notifica a tela
  void atualizarMeta(int novaMeta) {
    if (novaMeta > 0) { 
      _metaDiaria = novaMeta;
      notifyListeners();
    }
  }
}