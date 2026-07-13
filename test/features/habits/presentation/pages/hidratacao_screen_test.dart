import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinco_tigres_felizes/features/habits/presentation/pages/hydration_page.dart';
import 'package:provider/provider.dart';
import 'package:cinco_tigres_felizes/features/habits/services/hydration_service.dart';

void main() {
  testWidgets('Deve exibir a meta inicial e porcentagem zero', (
    WidgetTester tester,
  ) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'user-1'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => HidratacaoService(firestore: firestore, auth: auth),
          child: const HidratacaoScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifica se encontra o texto de 0%
    expect(find.text('0%'), findsOneWidget);

    // Verifica se o número 2000 (meta padrão) aparece
    expect(find.textContaining('2000'), findsWidgets);

    // Verifica se os botões existem pelo texto simples
    expect(find.textContaining('Copo'), findsOneWidget);
    expect(find.textContaining('Garrafa'), findsOneWidget);
  });
}
