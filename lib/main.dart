import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/features/access/presentation/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'features/habits/services/hydration_service.dart';

void main() {
  runApp(
    // Envelopamos o app no MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HidratacaoService()),
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
