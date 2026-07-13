import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:cinco_tigres_felizes/features/habits/presentation/pages/habits_page.dart';
import 'package:cinco_tigres_felizes/features/habits/providers/habitos_provider.dart';
import 'package:cinco_tigres_felizes/features/habits/services/habits_service.dart';
import 'package:cinco_tigres_felizes/features/gamification/models/badge_model.dart';
import 'package:cinco_tigres_felizes/features/gamification/providers/gamification_provider.dart';

class DummyGamificationProvider extends ChangeNotifier implements GamificationProvider {
  @override
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  List<BadgeModel> get badges => [];

  @override
  void avaliarConquistas(dynamic habito) {}
}

Widget _criarAppTeste({
  required HabitoService servico,
  Widget? home,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<GamificationProvider>(
        create: (_) => DummyGamificationProvider(),
      ),
      ChangeNotifierProvider<HabitosProvider>(
        create: (_) => HabitosProvider(servico, DummyGamificationProvider())..carregarHabitos(),
      ),
    ],
    child: MaterialApp(
      home: home ?? const HabitosScreen(),
    ),
  );
}

void main() {
  testWidgets('verifica persistência no Firestore após marcar e reiniciar', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'user-1'),
    );

    final servico = HabitoService(firestore: firestore, auth: auth);

    await tester.pumpWidget(
      _criarAppTeste(servico: servico),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Exercício');
    await tester.tap(find.text('Salvar hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Exercício'), findsOneWidget);

    // marca hoje
    final cardDoHabito = find.ancestor(
      of: find.text('Exercício'),
      matching: find.byType(Card),
    );
    final addDentroDoCard = find.descendant(
      of: cardDoHabito,
      matching: find.byIcon(Icons.add),
    );
    await tester.tap(addDentroDoCard);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check), findsOneWidget);

    // reinicia o app: nova instância do serviço apontando para o mesmo
    // backend (fake) do Firestore, simulando persistência entre execuções.
    await tester.pumpWidget(
      _criarAppTeste(servico: servico),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exercício'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}