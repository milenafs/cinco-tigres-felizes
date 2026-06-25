import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:cinco_tigres_felizes/main.dart';
import 'package:cinco_tigres_felizes/features/vaccines/presentation/pages/vaccine_page.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('opens vaccination screen from home button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VacinasService()),
        ],
        child: const MyApp(), 
      ),
    );

    expect(find.text('Abrir Vacinação'), findsOneWidget);
    expect(find.byIcon(Icons.vaccines), findsOneWidget);

    await tester.tap(find.text('Abrir Vacinação'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(VacinacaoScreen), findsOneWidget);
  });
}