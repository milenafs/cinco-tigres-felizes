import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/features/habits/models/habits_model.dart';
import 'package:cinco_tigres_felizes/features/achievements/providers/achievements_provider.dart';
import 'package:cinco_tigres_felizes/features/achievements/services/achievements_service.dart';

// Helper para criar hábito com um histórico específico para simular streak
HabitoModel criarHabitoComStreak(int diasConsecutivos) {
  Map<String, int> historico = {};
  final hoje = DateTime.now();
  
  for (int i = 0; i < diasConsecutivos; i++) {
    final data = hoje.subtract(Duration(days: i));
    final dataString = DateTime(data.year, data.month, data.day).toIso8601String().split('T').first;
    historico[dataString] = 1; 
  }

  return HabitoModel(
    id: 'habito_1',
    nome: 'Leitura',
    tipo: TipoFrequenciaHabito.diario,
    historico: historico,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GamificationProvider - avaliarConquistas', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late GamificationService service;
    late GlobalKey<ScaffoldMessengerState> scaffoldKey;
    
    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'user-1'));
      service = GamificationService(firestore: firestore, auth: auth);
      scaffoldKey = GlobalKey<ScaffoldMessengerState>();
    });

    test('NÃO desbloqueia selo se a meta de dias não foi atingida', () async {
      final provider = AchievementsProvider(scaffoldKey, service: service);
      
      // Dá tempo para o provider terminar o _carregarDoBanco() inicial
      await Future.delayed(const Duration(milliseconds: 50)); 

      // Hábito com 2 dias de streak (selo mínimo exige 3)
      final habito = criarHabitoComStreak(2);

      provider.avaliarConquistas(habito);
      
      // Dá tempo para a gravação no banco processar antes de validar
      await Future.delayed(const Duration(milliseconds: 50)); 

      final badge3Dias = provider.badges.firstWhere((b) => b.id == 'badge_3_dias');
      expect(badge3Dias.isDesbloqueado, isFalse);
    });

    test('DESBLOQUEIA selo se a meta foi atingida', () async {
      final provider = AchievementsProvider(scaffoldKey, service: service);
      await Future.delayed(const Duration(milliseconds: 50)); 

      // Hábito com 3 dias de streak exatos
      final habito = criarHabitoComStreak(3);

      provider.avaliarConquistas(habito);
      
      await Future.delayed(const Duration(milliseconds: 50)); 

      final badge3Dias = provider.badges.firstWhere((b) => b.id == 'badge_3_dias');
      expect(badge3Dias.isDesbloqueado, isTrue);
      expect(badge3Dias.desbloqueadoEm, isNotNull);
    });

    test('NÃO desbloqueia selo que já está desbloqueado', () async {
      // Pré-populando o banco falso para simular que o usuário JÁ TEM o selo
      await firestore.collection('users').doc('user-1').collection('conquistas').doc('badge_3_dias').set({
        'desbloqueadoEm': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final provider = AchievementsProvider(scaffoldKey, service: service);
      
      await Future.delayed(const Duration(milliseconds: 50)); 
      
      // Hábito com 4 dias (bateria a meta de novo, mas ele já tem o selo)
      final habito = criarHabitoComStreak(4);

      provider.avaliarConquistas(habito);
      
      await Future.delayed(const Duration(milliseconds: 50)); 

      final badge3Dias = provider.badges.firstWhere((b) => b.id == 'badge_3_dias');
      expect(badge3Dias.isDesbloqueado, isTrue);
      // Verifica se a data foi mantida (2025) e não sobrescrita com a data do teste atual
      expect(badge3Dias.desbloqueadoEm?.year, 2025);
    });
  });
}