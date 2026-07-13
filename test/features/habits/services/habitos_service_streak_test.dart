import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/features/habits/services/habits_service.dart';

String _chave(DateTime data) {
  final normalizado = DateTime(data.year, data.month, data.day);
  return normalizado.toIso8601String().split('T').first;
}

DateTime _hoje() => DateTime.now();
DateTime _dia(int offset) => _hoje().subtract(Duration(days: offset));

Future<void> _adicionarHistorico(
  FakeFirebaseFirestore firestore,
  String userId,
  String habitoId,
  Map<String, int> historico,
) async {
  for (final entry in historico.entries) {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitoId)
        .collection('history')
        .doc(entry.key)
        .set({'completedCount': entry.value, 'updatedAt': Timestamp.now()});
  }
}

void main() {
  group('alternarConclusao - atualização de maxStreak', () {
    test(
      'streak atual supera maxStreak: maxStreak é atualizado',
      () async {
        final firestore = FakeFirebaseFirestore();
        const userId = 'user-1';
        const habitoId = 'h1';
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: userId),
        );

        final service = HabitoService(firestore: firestore, auth: auth);

        // Cria hábito com maxStreak=0 e history com 5 dias consecutivos
        await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .set({
          'id': habitoId,
          'nome': 'Teste',
          'tipo': 0,
          'vezesPorDia': 1,
          'maxStreak': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Adiciona histórico: hoje e últimos 5 dias (6 dias completos)
        // Mas hoje está como 0 (incompleto), dias -1 a -5 completos
        // Após alternarConclusao(hoje), streak será 6
        await _adicionarHistorico(
          firestore,
          userId,
          habitoId,
          {
            for (int i = 1; i <= 5; i++) _chave(_dia(i)): 1,
          },
        );

        await service.alternarConclusao(habitoId, _hoje());

        final doc = await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .get();

        // streak calculado: hoje + 5 dias anteriores = 6
        expect(doc.data()!['maxStreak'], equals(6));
      },
    );

    test(
      'primeiro registro: maxStreak vai para 1',
      () async {
        final firestore = FakeFirebaseFirestore();
        const userId = 'user-1';
        const habitoId = 'h1';
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: userId),
        );

        final service = HabitoService(firestore: firestore, auth: auth);

        await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .set({
          'id': habitoId,
          'nome': 'Teste',
          'tipo': 0,
          'vezesPorDia': 1,
          'maxStreak': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        await service.alternarConclusao(habitoId, _hoje());

        final doc = await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .get();

        expect(doc.data()!['maxStreak'], equals(1));
      },
    );

    test(
      'streak não supera maxStreak: maxStreak não é alterado',
      () async {
        final firestore = FakeFirebaseFirestore();
        const userId = 'user-1';
        const habitoId = 'h1';
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: userId),
        );

        final service = HabitoService(firestore: firestore, auth: auth);

        await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .set({
          'id': habitoId,
          'nome': 'Teste',
          'tipo': 0,
          'vezesPorDia': 1,
          'maxStreak': 10,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        await service.alternarConclusao(habitoId, _hoje());

        final doc = await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .get();

        expect(doc.data()!['maxStreak'], equals(10));
      },
    );

    test(
      'desmarcar reduz streak mas não altera maxStreak',
      () async {
        final firestore = FakeFirebaseFirestore();
        const userId = 'user-1';
        const habitoId = 'h1';
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: userId),
        );

        final service = HabitoService(firestore: firestore, auth: auth);

        await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .set({
          'id': habitoId,
          'nome': 'Teste',
          'tipo': 0,
          'vezesPorDia': 1,
          'maxStreak': 5,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Adiciona histórico de 5 dias consecutivos (streak = 5)
        await _adicionarHistorico(
          firestore,
          userId,
          habitoId,
          {
            for (int i = 0; i < 5; i++) _chave(_dia(i)): 1,
          },
        );

        // Alternar conclusão hoje desmarca (remove histórico de hoje)
        await service.alternarConclusao(habitoId, _hoje());

        final doc = await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .get();

        // maxStreak não deve diminuir
        expect(doc.data()!['maxStreak'], equals(5));
      },
    );

    test(
      'marcar e desmarcar não reduz maxStreak abaixo do maior valor já atingido',
      () async {
        final firestore = FakeFirebaseFirestore();
        const userId = 'user-1';
        const habitoId = 'h1';
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: userId),
        );

        final service = HabitoService(firestore: firestore, auth: auth);

        await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .set({
          'id': habitoId,
          'nome': 'Teste',
          'tipo': 0,
          'vezesPorDia': 1,
          'maxStreak': 0,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Marca (streak=1, maxStreak vai a 1) e desmarca (streak=0)
        await service.alternarConclusao(habitoId, _hoje());
        await service.alternarConclusao(habitoId, _hoje());

        final doc = await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .get();

        // maxStreak não deve diminuir, fica em 1 (maior valor atingido)
        expect(doc.data()!['maxStreak'], equals(1));
      },
    );
  });

  group('carregarHabitos - leitura de maxStreak', () {
    test(
      'maxStreak salvo é carregado corretamente',
      () async {
        final firestore = FakeFirebaseFirestore();
        const userId = 'user-1';
        const habitoId = 'h1';
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: userId),
        );

        final service = HabitoService(firestore: firestore, auth: auth);

        await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .set({
          'id': habitoId,
          'nome': 'Teste',
          'tipo': 0,
          'vezesPorDia': 1,
          'maxStreak': 5,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Adiciona histórico de 3 dias para ter um hábito válido
        await _adicionarHistorico(
          firestore,
          userId,
          habitoId,
          {_chave(_dia(0)): 1, _chave(_dia(1)): 1, _chave(_dia(2)): 1},
        );

        final habitos = await service.carregarHabitos();

        expect(habitos.length, equals(1));
        expect(habitos.first.maxStreak, equals(5));
      },
    );

    test(
      'maxStreak padrão 0 quando campo não existe no Firestore',
      () async {
        final firestore = FakeFirebaseFirestore();
        const userId = 'user-1';
        const habitoId = 'h1';
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: userId),
        );

        final service = HabitoService(firestore: firestore, auth: auth);

        // Documento sem maxStreak
        await firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habitoId)
            .set({
          'id': habitoId,
          'nome': 'Teste',
          'tipo': 0,
          'vezesPorDia': 1,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        await _adicionarHistorico(
          firestore,
          userId,
          habitoId,
          {_chave(_dia(0)): 1},
        );

        final habitos = await service.carregarHabitos();

        expect(habitos.length, equals(1));
        expect(habitos.first.maxStreak, equals(0));
      },
    );
  });
}