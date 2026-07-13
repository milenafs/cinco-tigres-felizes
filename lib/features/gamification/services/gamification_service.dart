import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/badge_model.dart';

class GamificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Busca no Firestore os selos que o usuário já desbloqueou
  Future<Map<String, DateTime>> carregarConquistasDesbloqueadas() async {
    if (_userId == null) return {};

    final snapshot = await _db
        .collection('usuarios')
        .doc(_userId)
        .collection('conquistas')
        .get();

    final Map<String, DateTime> conquistas = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['desbloqueadoEm'] != null) {
        conquistas[doc.id] = (data['desbloqueadoEm'] as Timestamp).toDate();
      }
    }
    
    return conquistas;
  }

  /// Salva um novo selo desbloqueado no Firestore
  Future<void> salvarConquista(BadgeModel badge) async {
    if (_userId == null || badge.desbloqueadoEm == null) return;

    await _db
        .collection('usuarios')
        .doc(_userId)
        .collection('conquistas')
        .doc(badge.id) // O ID do documento é o ID do selo
        .set({
      'desbloqueadoEm': Timestamp.fromDate(badge.desbloqueadoEm!),
    });
  }
}