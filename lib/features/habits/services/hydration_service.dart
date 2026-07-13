import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/hydration_model.dart';

class HidratacaoService extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  int _consumoAtual = 0;
  int _metaDiaria = 2000;

  bool _carregado = false;

  HidratacaoService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = auth ?? FirebaseAuth.instance {
    _inicializar();
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

  /// users/{uid}/hydration/settings
  DocumentReference<Map<String, dynamic>> get _settingsRef => _firestore
      .collection('users')
      .doc(_uid)
      .collection('hydration')
      .doc('settings');

  /// users/{uid}/hydration/logs/entries/{yyyy-MM-dd}
  DocumentReference<Map<String, dynamic>> _logRef(DateTime data) {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('hydration')
        .doc('logs')
        .collection('entries')
        .doc(_dateKey(data));
  }

  String _dateKey(DateTime data) {
    final normalizada = DateTime(data.year, data.month, data.day);
    return normalizada.toIso8601String().split('T').first;
  }

  Future<void> _inicializar() async {
    await _carregarDados();
  }

  Future<void> _carregarDados() async {
    // SETTINGS

    final settingsSnapshot = await _settingsRef.get();

    if (settingsSnapshot.exists) {
      final data = settingsSnapshot.data();

      if (data != null) {
        _metaDiaria = data['metaDiaria'] ?? 2000;
      }
    } else {
      await _settingsRef.set({
        'metaDiaria': 2000,
        'updatedAt': Timestamp.now(),
      });
    }

    // LOG DO DIA

    final hoje = _logRef(DateTime.now());

    final logSnapshot = await hoje.get();

    if (logSnapshot.exists) {
      final data = logSnapshot.data();

      if (data != null) {
        _consumoAtual = data['consumoAtual'] ?? 0;
      }
    } else {
      await hoje.set({
        'consumoAtual': 0,
        'updatedAt': Timestamp.now(),
      });
    }

    _carregado = true;
    notifyListeners();
  }

  Future<void> _garantirCarregado() async {
    if (_carregado) return;

    await _carregarDados();
  }

  HidratacaoModel get model => HidratacaoModel(
        metaDiaria: _metaDiaria,
        consumoAtual: _consumoAtual,
      );

  Future<void> adicionarAgua(int quantidade) async {
    await _garantirCarregado();

    _consumoAtual += quantidade;

    await _logRef(DateTime.now()).set({
      'consumoAtual': _consumoAtual,
      'updatedAt': Timestamp.now(),
    });

    notifyListeners();
  }

  Future<void> atualizarMeta(int novaMeta) async {
    if (novaMeta <= 0) return;

    await _garantirCarregado();

    _metaDiaria = novaMeta;

    await _settingsRef.set({
      'metaDiaria': novaMeta,
      'updatedAt': Timestamp.now(),
    });

    notifyListeners();
  }

  Future<void> zerarDia() async {
    await _garantirCarregado();

    _consumoAtual = 0;

    await _logRef(DateTime.now()).set({
      'consumoAtual': 0,
      'updatedAt': Timestamp.now(),
    });

    notifyListeners();
  }

  Future<void> carregarNovamente() async {
    _carregado = false;
    await _carregarDados();
  }
}