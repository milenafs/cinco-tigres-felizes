import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/features/habits/models/habits_model.dart';
import 'package:cinco_tigres_felizes/features/habits/providers/habitos_provider.dart';
import 'package:cinco_tigres_felizes/features/habits/services/habits_service.dart';
import 'package:cinco_tigres_felizes/features/achievements/models/badge_model.dart';
import 'package:cinco_tigres_felizes/features/achievements/providers/achievements_provider.dart';

/// Dummy Mock para isolar o AchievementsProvider nos testes
class DummyAchievementsProvider extends ChangeNotifier implements AchievementsProvider {
  @override
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  List<BadgeModel> get badges => [];

  @override
  void avaliarConquistas(HabitoModel habito) {}
}

/// Helper para criar um [HabitoModel] para testes.
HabitoModel criarHabito({
  String nome = 'Teste',
  String? id,
}) {
  return HabitoModel(
    id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    nome: nome,
    tipo: TipoFrequenciaHabito.diario,
  );
}

void main() {
  group('HabitosProvider - carregamento', () {
    test(
      'criado sem carregar: carregando inicia como true',
      () {
        final firestore = FakeFirebaseFirestore();
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'user-1'),
        );
        final servico = HabitoService(firestore: firestore, auth: auth);

        final provider = HabitosProvider(servico, DummyAchievementsProvider());

        expect(provider.carregando, isTrue);
        expect(provider.habitos, isEmpty);
        expect(provider.erro, isNull);
      },
    );

    test(
      'carregarHabitos completa e carregando vai para false',
      () async {
        final firestore = FakeFirebaseFirestore();
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'user-1'),
        );
        final servico = HabitoService(firestore: firestore, auth: auth);

        final provider = HabitosProvider(servico, DummyAchievementsProvider());
        expect(provider.carregando, isTrue);

        await provider.carregarHabitos();

        expect(provider.carregando, isFalse);
        expect(provider.erro, isNull);
      },
    );

    test(
      'criado com cascade ..carregarHabitos() termina o loading',
      () async {
        final firestore = FakeFirebaseFirestore();
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'user-1'),
        );
        final servico = HabitoService(firestore: firestore, auth: auth);

        final provider = HabitosProvider(servico, DummyAchievementsProvider())..carregarHabitos();

        // Inicialmente está carregando
        expect(provider.carregando, isTrue);

        // Aguarda a Future completar
        await Future(() {});

        // Após processar o microtask, o carregamento deve ter terminado
        expect(provider.carregando, isFalse);
        expect(provider.erro, isNull);
      },
    );

    test(
      'carregarHabitos com erro: carregando vai para false e erro é definido',
      () async {
        final firestore = FakeFirebaseFirestore();
        final auth = MockFirebaseAuth(
          signedIn: false,
        );
        final servico = HabitoService(firestore: firestore, auth: auth);

        final provider = HabitosProvider(servico, DummyAchievementsProvider());
        expect(provider.carregando, isTrue);

        await provider.carregarHabitos();

        expect(provider.carregando, isFalse);
        expect(provider.erro, isNotNull);
        expect(provider.erro, contains('Erro ao carregar hábitos'));
      },
    );
  });

  group('HabitosProvider - operações', () {
    test(
      'adicionarHabito insere na lista localmente',
      () async {
        final firestore = FakeFirebaseFirestore();
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'user-1'),
        );
        final servico = HabitoService(firestore: firestore, auth: auth);

        final provider = HabitosProvider(servico, DummyAchievementsProvider())..carregarHabitos();
        await Future(() {});

        expect(provider.habitos, isEmpty);

        await provider.adicionarHabito(
          criarHabito(nome: 'Meditar'),
        );

        expect(provider.habitos.length, 1);
        expect(provider.habitos.first.nome, 'Meditar');
      },
    );

    test(
      'alternarConclusao atualiza localmente (otimista)',
      () async {
        final firestore = FakeFirebaseFirestore();
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'user-1'),
        );
        final servico = HabitoService(firestore: firestore, auth: auth);

        final provider = HabitosProvider(servico, DummyAchievementsProvider())..carregarHabitos();
        await Future(() {});

        await provider.adicionarHabito(
          criarHabito(nome: 'Exercício'),
        );

        expect(provider.habitos.first.estaConcluidoEm(DateTime.now()), isFalse);

        await provider.alternarConclusao(
          provider.habitos.first.id,
          DateTime.now(),
        );

        // Atualização otimista: deve estar concluído imediatamente
        expect(provider.habitos.first.estaConcluidoEm(DateTime.now()), isTrue);
      },
    );

    test(
      'removerHabito remove da lista localmente',
      () async {
        final firestore = FakeFirebaseFirestore();
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'user-1'),
        );
        final servico = HabitoService(firestore: firestore, auth: auth);

        final provider = HabitosProvider(servico, DummyAchievementsProvider())..carregarHabitos();
        await Future(() {});

        await provider.adicionarHabito(
          criarHabito(nome: 'Beber água'),
        );

        expect(provider.habitos.length, 1);

        await provider.removerHabito(provider.habitos.first.id);

        expect(provider.habitos, isEmpty);
      },
    );
  });
}