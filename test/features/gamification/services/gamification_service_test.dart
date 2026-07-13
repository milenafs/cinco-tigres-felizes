import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/gamification/models/badge_model.dart';
import 'package:cinco_tigres_felizes/features/gamification/services/gamification_service.dart';

void main() {
  group('GamificationService', () {
    test('carregarConquistasDesbloqueadas retorna mapa vazio se não houver conquistas', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'user-1'));
      final service = GamificationService(firestore: firestore, auth: auth);

      final conquistas = await service.carregarConquistasDesbloqueadas();

      expect(conquistas, isEmpty);
    });

    test('salvarConquista e carregarConquistasDesbloqueadas funcionam corretamente', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'user-1'));
      final service = GamificationService(firestore: firestore, auth: auth);

      final dataDesbloqueio = DateTime(2026, 10, 10);
      final badge = BadgeModel(
        id: 'badge_teste',
        titulo: 'Teste',
        descricaoCondicao: 'Condição',
        metaDiasConsecutivos: 3,
        iconePath: 'path.png',
        desbloqueadoEm: dataDesbloqueio,
      );

      // Salva no Firestore falso
      await service.salvarConquista(badge);

      // Carrega do Firestore falso
      final conquistas = await service.carregarConquistasDesbloqueadas();

      expect(conquistas.length, 1);
      expect(conquistas.containsKey('badge_teste'), isTrue);
      // O Firestore perde a precisão de microssegundos, então comparamos ano/mês/dia
      expect(conquistas['badge_teste']?.year, dataDesbloqueio.year);
      expect(conquistas['badge_teste']?.month, dataDesbloqueio.month);
      expect(conquistas['badge_teste']?.day, dataDesbloqueio.day);
    });
  });
}