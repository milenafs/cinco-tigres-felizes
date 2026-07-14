import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Importações originais
import 'package:cinco_tigres_felizes/features/auth/presentation/pages/login_page.dart';
import 'package:cinco_tigres_felizes/features/auth/providers/auth_provider.dart';
import 'package:cinco_tigres_felizes/features/habits/providers/habitos_provider.dart';
import 'package:cinco_tigres_felizes/features/habits/services/habits_service.dart';
import 'package:cinco_tigres_felizes/features/habits/services/hydration_service.dart';
import 'package:cinco_tigres_felizes/features/vaccines/data/repositories/vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';

// Nova importação (ajuste o caminho conforme criou as pastas)
import 'package:cinco_tigres_felizes/features/achievements/providers/achievements_provider.dart';

// Chave global para podermos exibir SnackBars (notificações) sem precisar de um BuildContext
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HidratacaoService()),

        // 1. Adicionamos o AchievementsProvider ANTES do HabitosProvider
        // Passamos a chave global para ele conseguir disparar os pop-ups
        ChangeNotifierProvider(
          create: (_) => AchievementsProvider(scaffoldMessengerKey),
        ),

        // 2. Trocamos o ChangeNotifierProvider do HabitosProvider por um ChangeNotifierProxyProvider.
        // Isso permite injetar o AchievementsProvider dentro do HabitosProvider de forma segura.
        ChangeNotifierProxyProvider<AchievementsProvider, HabitosProvider>(
          create: (context) => HabitosProvider(
            HabitoService(),
            context.read<AchievementsProvider>(), // Injetando aqui
          )..carregarHabitos(),
          update: (context, achievements, previous) => 
              previous ?? HabitosProvider(HabitoService(), achievements)..carregarHabitos(),
        ),

        Provider<IVacinasRepository>(create: (_) => VacinasRepository()),
        ChangeNotifierProxyProvider<IVacinasRepository, VacinasService>(
          create: (ctx) => VacinasService(ctx.read<IVacinasRepository>()),
          update: (_, repo, previous) => previous ?? VacinasService(repo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      scaffoldMessengerKey: scaffoldMessengerKey, // <-- Conectamos a chave global aqui!
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00897B), width: 2),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}