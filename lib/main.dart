import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/features/access/presentation/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'features/habits/services/hydration_service.dart';
import 'package:cinco_tigres_felizes/features/vaccines/data/repositories/vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/repositories/i_vaccines_repository.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HidratacaoService()),

        // Substituir o ChangeNotifierProvider antigo por estes dois:
        Provider<IVacinasRepository>(
          create: (_) => VacinasRepository(),
        ),
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
      home: const HomeScreen(),
    );
  }
}