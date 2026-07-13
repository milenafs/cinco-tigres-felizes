import 'package:flutter/material.dart';
import '../../habits/models/habits_model.dart'; 
import '../models/badge_model.dart';
import '../services/gamification_service.dart';

class GamificationProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final GamificationService _service = GamificationService();

  GamificationProvider(this.scaffoldMessengerKey) {
    _carregarDoBanco(); // Carrega as conquistas ao iniciar o app
  }

  final List<BadgeModel> _badges = [
    BadgeModel(
      id: 'badge_3_dias',
      titulo: 'Aquecimento',
      descricaoCondicao: 'Complete 3 dias consecutivos em qualquer hábito.',
      metaDiasConsecutivos: 3,
      iconePath: 'assets/icons/fire.png',
    ),
    BadgeModel(
      id: 'badge_7_dias',
      titulo: 'Consistência de Aço',
      descricaoCondicao: 'Complete 7 dias consecutivos em qualquer hábito.',
      metaDiasConsecutivos: 7,
      iconePath: 'assets/icons/medal.png',
    ),
    BadgeModel(
      id: 'badge_15_dias',
      titulo: 'Hábito Formado',
      descricaoCondicao: 'Complete 15 dias consecutivos. Você está pegando o jeito!',
      metaDiasConsecutivos: 15,
      iconePath: 'assets/icons/star.png', 
    ),
    BadgeModel(
      id: 'badge_30_dias',
      titulo: 'Invencível',
      descricaoCondicao: 'Um mês inteiro! Complete 30 dias consecutivos.',
      metaDiasConsecutivos: 30,
      iconePath: 'assets/icons/trophy.png',
    ),
    BadgeModel(
      id: 'badge_100_dias',
      titulo: 'Lenda Viva',
      descricaoCondicao: 'Complete 100 dias consecutivos. Disciplina inabalável.',
      metaDiasConsecutivos: 100,
      iconePath: 'assets/icons/crown.png',
    ),
  ];

  List<BadgeModel> get badges => List.unmodifiable(_badges);

  /// Carrega as datas salvas no Firestore e atualiza a lista local
  Future<void> _carregarDoBanco() async {
    try {
      final conquistasSalvas = await _service.carregarConquistasDesbloqueadas();
      
      if (conquistasSalvas.isNotEmpty) {
        for (int i = 0; i < _badges.length; i++) {
          final id = _badges[i].id;
          if (conquistasSalvas.containsKey(id)) {
            _badges[i] = _badges[i].copyWith(desbloqueadoEm: conquistasSalvas[id]);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar conquistas: $e');
    }
  }

  void avaliarConquistas(HabitoModel habito) async {
    final int streakAtual = habito.calcularStreak();
    bool houveDesbloqueio = false;

    for (int i = 0; i < _badges.length; i++) {
      final badge = _badges[i];
      
      if (!badge.isDesbloqueado && streakAtual >= badge.metaDiasConsecutivos) {
        // Atualiza localmente
        _badges[i] = badge.copyWith(desbloqueadoEm: DateTime.now());
        houveDesbloqueio = true;
        
        // Mostra animação na tela
        _mostrarAnimacaoDesbloqueio(_badges[i]);
        
        // Salva no Firestore
        _service.salvarConquista(_badges[i]);
      }
    }

    if (houveDesbloqueio) {
      notifyListeners();
    }
  }

  void _mostrarAnimacaoDesbloqueio(BadgeModel badge) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Novo Selo Desbloqueado!', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(badge.titulo),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}