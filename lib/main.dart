import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:cinco_tigres_felizes/features/auth/presentation/pages/login_page.dart';
import 'package:cinco_tigres_felizes/features/auth/providers/auth_provider.dart';
import 'package:cinco_tigres_felizes/features/habits/services/hydration_service.dart';
import 'package:cinco_tigres_felizes/features/vaccines/data/repositories/vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HidratacaoService()),

        // Substituir o ChangeNotifierProvider antigo por estes dois:
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
    );
  }
}
