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

  DocumentReference<Map<String, dynamic>> _habitDocument(String habitoId) =>
      _firestore.collection('users').doc(_uid).collection('habits').doc(habitoId);

  TipoFrequenciaHabito _tipoFromValue(dynamic value) {
    final tipoIndex = value is int ? value : 0;
    return TipoFrequenciaHabito.values[tipoIndex.clamp(
      0,
      TipoFrequenciaHabito.values.length - 1,
    )];
  }

  /// Cria um [HabitoModel] a partir de um documento do Firestore,
  /// extraindo o history inline do campo 'history' (Map de String para int).
  HabitoModel _habitoFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final historyRaw = data['history'];
    final historico = <String, int>{};
    if (historyRaw is Map) {
      for (final entry in historyRaw.entries) {
        final value = entry.value;
        historico[entry.key.toString()] = value is int ? value : 1;
      }
    }

    return HabitoModel(
      id: data['id'] as String? ?? doc.id,
      nome: data['nome'] as String? ?? '',
      tipo: _tipoFromValue(data['tipo']),
      vezesPorDia: data['vezesPorDia'] is int ? data['vezesPorDia'] as int : 1,
      historico: historico,
      maxStreak: data['maxStreak'] is int ? data['maxStreak'] as int : 0,
    );
  }

  /// Carrega todos os hábitos do usuário. Uma única chamada por hábito,
  /// pois o history é inline no documento (sem subcoleção).
  Future<List<HabitoModel>> carregarHabitos() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .get();

    return snapshot.docs.map((doc) => _habitoFromDoc(doc)).toList();
  }

  /// Adiciona um novo hábito no Firestore.
  Future<void> adicionarHabito(HabitoModel habito) async {
    final docRef = _habitDocument(habito.id);
    final now = Timestamp.now();

    await docRef.set({
      ...habito.toFirestoreDoc(),
      'createdAt': now,
      'updatedAt': now,
    });
  }

  /// Alterna a conclusão de um hábito em uma data específica.
  /// Retorna o [HabitoModel] atualizado para que o provider possa
  /// fazer atualização otimista.
  Future<HabitoModel> alternarConclusao(
    String habitoId,
    DateTime data, {
    HabitoModel? estadoLocal,
  }) async {
    // Se temos o estado local vindo do provider (já atualizado otimistamente),
    // apenas persistimos no Firestore sem re-aplicar o toggle.
    if (estadoLocal != null) {
      // Recalcular o maxStreak para garantir consistência
      final streakAtual = estadoLocal.calcularStreak();
      final novoMaxStreak = streakAtual > estadoLocal.maxStreak
          ? streakAtual
          : estadoLocal.maxStreak;
      final docAtualizado = estadoLocal.copyWith(maxStreak: novoMaxStreak);

      await _habitDocument(habitoId).update(docAtualizado.toFirestoreDoc());
      return docAtualizado;
    }

    // Fallback: ler do Firestore
    final docRef = _habitDocument(habitoId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception('Hábito não encontrado: $habitoId');
    }

    final habito = _habitoFromDoc(docSnapshot);
    final atualizado = habito.alternarConclusao(data);
    final streakAtual = atualizado.calcularStreak();
    final novoMaxStreak = streakAtual > atualizado.maxStreak
        ? streakAtual
        : atualizado.maxStreak;

    final docAtualizado = atualizado.copyWith(maxStreak: novoMaxStreak);

    await docRef.update(docAtualizado.toFirestoreDoc());

    return docAtualizado;
  }

  /// Atualiza os dados de um hábito (nome, tipo, etc.).
  Future<void> atualizarHabito(HabitoModel habitoAtualizado) async {
    await _habitDocument(habitoAtualizado.id).update(
      habitoAtualizado.toFirestoreDoc(),
    );
  }

  /// Remove um hábito e seus dados do Firestore.
  Future<void> removerHabito(String habitoId) async {
    await _habitDocument(habitoId).delete();
  }
}