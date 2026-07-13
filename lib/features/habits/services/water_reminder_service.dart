import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/water_reminder_model.dart';

class WaterReminderService extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  LembreteAguaModel? _lembrete;
  bool _carregado = false;

  WaterReminderService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = auth ?? FirebaseAuth.instance {
    carregarLembrete();
  }

  String get _uid {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Usuário não autenticado.',
      );
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _settingsRef => _firestore
      .collection('users')
      .doc(_uid)
      .collection('water_reminder')
      .doc('settings');

  LembreteAguaModel? get lembrete => _lembrete;

  Future<void> carregarLembrete() async {
    final snapshot = await _settingsRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        _lembrete = LembreteAguaModel.fromJson(data);
      }
    } else {
      _lembrete = null;
    }

    _carregado = true;
    notifyListeners();
  }

  Future<void> salvarLembrete(LembreteAguaModel lembrete) async {
    _lembrete = lembrete;
    await _settingsRef.set({
      ...lembrete.toJson(),
      'updatedAt': Timestamp.now(),
    });
    _carregado = true;
    notifyListeners();
  }

  Future<void> atualizarLembrete(LembreteAguaModel lembrete) async {
    await salvarLembrete(lembrete);
  }

  Future<void> garantirCarregado() async {
    if (_carregado) {
      return;
    }
    await carregarLembrete();
  }
}
