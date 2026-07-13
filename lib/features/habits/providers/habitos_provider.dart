import 'package:flutter/foundation.dart';

import '../models/habits_model.dart';
import '../services/habits_service.dart';

/// Provider que gerencia o estado dos hábitos com cache local
/// e atualizações otimistas para garantir uma UI fluida.
class HabitosProvider extends ChangeNotifier {
  final HabitoService _servico;

  HabitosProvider(this._servico);

  List<HabitoModel> _habitos = [];
  bool _carregando = true;
  String? _erro;

  List<HabitoModel> get habitos => List.unmodifiable(_habitos);
  bool get carregando => _carregando;
  String? get erro => _erro;

  /// Carrega os hábitos do Firestore (chamado uma vez ao iniciar).
  Future<void> carregarHabitos() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _habitos = await _servico.carregarHabitos();
    } catch (e) {
      _erro = 'Erro ao carregar hábitos: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Alterna a conclusão de um hábito com **atualização otimista**.
  /// A UI é atualizada instantaneamente antes da confirmação do Firestore.
  Future<void> alternarConclusao(String habitoId, DateTime data) async {
    final index = _habitos.indexWhere((h) => h.id == habitoId);
    if (index == -1) return;

    // Salva o estado original para possível rollback
    final estadoOriginal = _habitos[index];

    // Aplica a mudança localmente (otimista)
    final atualizado = estadoOriginal.alternarConclusao(data);
    final streakAtual = atualizado.calcularStreak();
    final novoMaxStreak = streakAtual > atualizado.maxStreak
        ? streakAtual
        : atualizado.maxStreak;
    _habitos[index] = atualizado.copyWith(maxStreak: novoMaxStreak);

    // Notifica a UI imediatamente
    notifyListeners();

    try {
      // Persiste no Firestore em background
      await _servico.alternarConclusao(
        habitoId,
        data,
        estadoLocal: _habitos[index],
      );
    } catch (e) {
      // Rollback se o Firestore falhar
      _habitos[index] = estadoOriginal;
      _erro = 'Erro ao salvar: $e';
      notifyListeners();
    }
  }

  /// Adiciona um novo hábito localmente e persiste no Firestore.
  Future<void> adicionarHabito(HabitoModel habito) async {
    _habitos.insert(0, habito);
    notifyListeners();

    try {
      await _servico.adicionarHabito(habito);
    } catch (e) {
      _habitos.removeWhere((h) => h.id == habito.id);
      _erro = 'Erro ao adicionar hábito: $e';
      notifyListeners();
    }
  }

  /// Atualiza um hábito localmente e persiste no Firestore.
  Future<void> atualizarHabito(HabitoModel habitoAtualizado) async {
    final index = _habitos.indexWhere((h) => h.id == habitoAtualizado.id);
    if (index == -1) return;

    final estadoOriginal = _habitos[index];
    _habitos[index] = habitoAtualizado;
    notifyListeners();

    try {
      await _servico.atualizarHabito(habitoAtualizado);
    } catch (e) {
      _habitos[index] = estadoOriginal;
      _erro = 'Erro ao atualizar hábito: $e';
      notifyListeners();
    }
  }

  /// Remove um hábito localmente e persiste no Firestore.
  Future<void> removerHabito(String habitoId) async {
    final index = _habitos.indexWhere((h) => h.id == habitoId);
    if (index == -1) return;

    final estadoOriginal = _habitos[index];
    _habitos.removeAt(index);
    notifyListeners();

    try {
      await _servico.removerHabito(habitoId);
    } catch (e) {
      _habitos.insert(index, estadoOriginal);
      _erro = 'Erro ao remover hábito: $e';
      notifyListeners();
    }
  }
}