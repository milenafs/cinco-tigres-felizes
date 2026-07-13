import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/features/habits/models/habits_model.dart';
import 'package:cinco_tigres_felizes/features/habits/services/habits_service.dart';

void main() {
  test('HabitoService persiste historico entre leituras', () async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'user-1'),
    );

    final service = HabitoService(firestore: firestore, auth: auth);

    final habito = HabitoModel(
      id: 'h1',
      nome: 'Teste',
      tipo: TipoFrequenciaHabito.diario,
    );

    // adiciona e verifica
    await service.adicionarHabito(habito);
    var lista = await service.carregarHabitos();
    expect(lista.length, 1);

    // marca hoje
    await service.alternarConclusao('h1', DateTime.now());
    lista = await service.carregarHabitos();
    expect(lista.first.estaConcluidoEm(DateTime.now()), isTrue);

    // re-carrega em nova instância, apontando para o mesmo firestore fake
    final service2 = HabitoService(firestore: firestore, auth: auth);
    final lista2 = await service2.carregarHabitos();
    expect(lista2.first.estaConcluidoEm(DateTime.now()), isTrue);
  });
}
