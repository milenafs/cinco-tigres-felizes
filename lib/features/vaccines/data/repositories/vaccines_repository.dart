import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/data/models/vaccine_model.dart';

class VacinasRepository implements IVacinasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static const List<String> _categorias = [
    'crianca_0_10',
    'adolescente_11_19',
    'adulto_20_59',
    'gestante',
    'idoso_60_mais',
  ];

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

  CollectionReference<Map<String, dynamic>> get _progressCollection =>
      _firestore.collection('users').doc(_uid).collection('vaccines_progress');

  CollectionReference<Map<String, dynamic>> _vaccinesCollection(
    String category,
  ) => _firestore.collection('vaccines').doc(category).collection('vaccines');

  List<Vacina> _parseVacinas(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return VacinaModel(
        nome: data['nome'] as String? ?? '',
        descricao: data['descricao'] as String? ?? '',
        doseTexto: data['dose_texto'] as String? ?? '',
        quantidadeDeDoses: data['quantidade_doses'] is int
            ? data['quantidade_doses'] as int
            : int.tryParse(data['quantidade_doses']?.toString() ?? '0') ?? 0,
      );
    }).toList();
  }

  Future<List<Vacina>> _carregarVacinasDaCategoria(String categoria) async {
    final snapshot = await _vaccinesCollection(categoria).get();
    return _parseVacinas(snapshot);
  }

  @override
  Future<CalendarioVacinas> carregarCalendario() async {
    final resultados = await Future.wait(
      _categorias.map(_carregarVacinasDaCategoria),
    );

    return CalendarioVacinasModel(
      criancas: resultados[0],
      adolescentes: resultados[1],
      adultos: resultados[2],
      gestantes: resultados[3],
      idosos: resultados[4],
    );
  }

  @override
  Future<Map<String, List<bool>>> carregarDoses() async {
    final snapshot = await _progressCollection.get();
    final dosesPorVacina = <String, List<bool>>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final dosesRaw = data['doses'];
      if (dosesRaw is List) {
        dosesPorVacina[doc.id] = List<bool>.from(dosesRaw);
      }
    }

    return dosesPorVacina;
  }

  @override
  Future<void> salvarDoses(Map<String, List<bool>> doses) async {
    final batch = _firestore.batch();

    for (final entry in doses.entries) {
      batch.set(_progressCollection.doc(entry.key), {
        'doses': entry.value,
        'updatedAt': Timestamp.now(),
      });
    }

    await batch.commit();
  }
}
