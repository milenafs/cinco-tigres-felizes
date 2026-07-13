import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:cinco_tigres_felizes/features/access/presentation/pages/home_page.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/presentation/pages/vaccine_page.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';

import './helpers/fake_vaccines_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseAuth auth;

  setUp(() async {
    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: '123',
        email: 'milena@email.com',
        displayName: 'Milena',
      ),
    );
  });

  testWidgets('abre a tela de vacinação a partir da home', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<IVacinasRepository>(create: (_) => FakeVacinasRepository()),
          ChangeNotifierProxyProvider<IVacinasRepository, VacinasService>(
            create: (context) =>
                VacinasService(context.read<IVacinasRepository>()),
            update: (_, repo, previous) => previous ?? VacinasService(repo),
          ),
        ],
        child: MaterialApp(home: HomeScreen(auth: auth)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Vacinação'), findsOneWidget);

    await tester.tap(find.text('Vacinação'));
    await tester.pumpAndSettle();

    expect(find.byType(VacinacaoScreen), findsOneWidget);
  });
}
