import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinco_tigres_felizes/features/access/presentation/pages/home_page.dart';
import 'package:cinco_tigres_felizes/features/habits/presentation/pages/habits_page.dart';
import 'package:cinco_tigres_felizes/features/habits/services/habits_service.dart';

void main() {
  testWidgets('navega para a tela de hábitos a partir da home', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'user-1'));

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          auth: auth,
          habitoService: HabitoService(firestore: firestore, auth: auth),
        ),
      ),
    );

    expect(find.text('Hábitos'), findsOneWidget);
    await tester.tap(find.text('Hábitos'));
    await tester.pumpAndSettle();

    expect(find.byType(HabitosScreen), findsOneWidget);
    expect(find.text('Nenhum hábito encontrado.'), findsOneWidget);
  });

  testWidgets('adiciona hábito e exibe cartão na lista', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'user-1'));

    await tester.pumpWidget(
      MaterialApp(
        home: HabitosScreen(
          service: HabitoService(firestore: firestore, auth: auth),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Meditar');
    await tester.tap(find.text('Salvar hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Meditar'), findsOneWidget);
    expect(find.text('Diário'), findsOneWidget);
  });

  testWidgets('marca conclusão de hoje e persiste entre reinícios', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'user-1'));

    await tester.pumpWidget(
      MaterialApp(
        home: HabitosScreen(
          service: HabitoService(firestore: firestore, auth: auth),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Exercício');
    await tester.tap(find.text('Salvar hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Exercício'), findsOneWidget);

    // Encontra o Card do hábito e clica no botão de marcar hoje dentro dele
    final cardDoHabitoLocal = find.ancestor(
      of: find.text('Exercício'),
      matching: find.byType(Card),
    );
    expect(cardDoHabitoLocal, findsOneWidget);
    final addDentroDoCard = find.descendant(
      of: cardDoHabitoLocal,
      matching: find.byIcon(Icons.add),
    );
    expect(addDentroDoCard, findsOneWidget);
    await tester.tap(addDentroDoCard);
    await tester.pumpAndSettle();

    // Agora deve mostrar o ícone de check (concluído) - assert local UI state
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Validar persistência diretamente no Firestore (nova instância do serviço,
    // simulando um reinício do app apontando para o mesmo backend)
    final servicoAposReinicio = HabitoService(firestore: firestore, auth: auth);
    final lista = await servicoAposReinicio.carregarHabitos();
    expect(lista.length, 1);
    expect(lista.first.nome, 'Exercício');
    expect(lista.first.estaConcluidoEm(DateTime.now()), isTrue);
  });
}
