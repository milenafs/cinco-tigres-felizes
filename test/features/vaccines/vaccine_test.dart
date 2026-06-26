import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cinco_tigres_felizes/main.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/presentation/pages/vaccine_page.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';
import './helpers/fake_vaccines_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('abre a tela de vacinação a partir do botão na home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<IVacinasRepository>(
            create: (_) => FakeVacinasRepository(),
          ),
          ChangeNotifierProxyProvider<IVacinasRepository, VacinasService>(
            create: (ctx) => VacinasService(ctx.read<IVacinasRepository>()),
            update: (_, repo, previous) => previous ?? VacinasService(repo),
          ),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('Abrir Vacinação'), findsOneWidget);
    expect(find.byIcon(Icons.vaccines), findsOneWidget);

    await tester.tap(find.text('Abrir Vacinação'));
    await tester.pumpAndSettle();

    expect(find.byType(VacinacaoScreen), findsOneWidget);
  });
}
