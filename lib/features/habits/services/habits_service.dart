import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/habits_model.dart';

class HabitoService {
  HabitoService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

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

  CollectionReference<Map<String, dynamic>> get _habitsCollection =>
      _firestore.collection('users').doc(_uid).collection('habits');

  DocumentReference<Map<String, dynamic>> _habitDocument(String habitoId) =>
      _habitsCollection.doc(habitoId);

  CollectionReference<Map<String, dynamic>> _historyCollection(
    String habitoId,
  ) => _habitDocument(habitoId).collection('history');

  String _dataChave(DateTime data) {
    final normalizado = DateTime(data.year, data.month, data.day);
    return normalizado.toIso8601String().split('T').first;
  }

  TipoFrequenciaHabito _tipoFromValue(dynamic value) {
    final tipoIndex = value is int ? value : 0;
    return TipoFrequenciaHabito.values[tipoIndex.clamp(
      0,
      TipoFrequenciaHabito.values.length - 1,
    )];
  }

  HabitoModel _habitoFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, int> historico,
  ) {
    final data = doc.data();
    return HabitoModel(
      id: data['id'] as String? ?? doc.id,
      nome: data['nome'] as String? ?? '',
      tipo: _tipoFromValue(data['tipo']),
      vezesPorDia: data['vezesPorDia'] is int ? data['vezesPorDia'] as int : 1,
      historico: historico,
      maxStreak: data['maxStreak'] is int ? data['maxStreak'] as int : 0,
    );
  }

  Future<Map<String, int>> _carregarHistorico(String habitoId) async {
    final historicoSnapshot = await _historyCollection(habitoId).get();
    final historico = <String, int>{};

    for (final doc in historicoSnapshot.docs) {
      final data = doc.data();
      final completedCount = data['completedCount'];
      historico[doc.id] = completedCount is int ? completedCount : 0;
    }

    return historico;
  }

  Future<List<HabitoModel>> carregarHabitos() async {
    final habitosSnapshot = await _habitsCollection.get();
    if (habitosSnapshot.docs.isEmpty) {
      return [];
    }

    final habitos = <HabitoModel>[];

    for (final doc in habitosSnapshot.docs) {
      final historico = await _carregarHistorico(doc.id);
      habitos.add(_habitoFromDoc(doc, historico));
    }

    return habitos;
  }

  Future<void> adicionarHabito(HabitoModel habito) async {
    final docRef = _habitDocument(habito.id);
    final now = Timestamp.now();

    await docRef.set({
      'id': habito.id,
      'nome': habito.nome,
      'tipo': habito.tipo.index,
      'vezesPorDia': habito.vezesPorDia,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> alternarConclusao(String habitoId, DateTime data) async {
    final docRef = _habitDocument(habitoId);
    final habitSnapshot = await docRef.get();
    if (!habitSnapshot.exists) {
      return;
    }

    final historicoAtual = await _carregarHistorico(habitoId);
    final habitData = habitSnapshot.data() ?? <String, dynamic>{};
    final habito = HabitoModel(
      id: habitData['id'] as String? ?? habitoId,
      nome: habitData['nome'] as String? ?? '',
      tipo: _tipoFromValue(habitData['tipo']),
      vezesPorDia: habitData['vezesPorDia'] is int
          ? habitData['vezesPorDia'] as int
          : 1,
      historico: historicoAtual,
    );

    final atualizado = habito.alternarConclusao(data);
    final chaveData = _dataChave(data);
    final countAtualizado = atualizado.historico[chaveData];
    final historyDoc = _historyCollection(habitoId).doc(chaveData);

    if (countAtualizado == null || countAtualizado == 0) {
      await historyDoc.delete();
    } else {
      await historyDoc.set({
        'completedCount': countAtualizado,
        'updatedAt': Timestamp.now(),
      });
    }

    // Calcular streak e atualizar maxStreak se necessário
    final streakAtual = atualizado.calcularStreak();
    final maxStreakAtual = habitData['maxStreak'] as int? ?? 0;
    if (streakAtual > maxStreakAtual) {
      await docRef.update({
        'maxStreak': streakAtual,
        'updatedAt': Timestamp.now(),
      });
    }
  }

  Future<void> atualizarHabito(HabitoModel habitoAtualizado) async {
    await _habitDocument(habitoAtualizado.id).update({
      'nome': habitoAtualizado.nome,
      'tipo': habitoAtualizado.tipo.index,
      'vezesPorDia': habitoAtualizado.vezesPorDia,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> removerHabito(String habitoId) async {
    final firestore = _firestore;
    final habitRef = firestore
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .doc(habitoId);
    final historyRef = habitRef.collection('history');

    final historySnapshot = await historyRef.get();
    final batch = firestore.batch();

    for (final doc in historySnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(habitRef);
    await batch.commit();
  }
}
