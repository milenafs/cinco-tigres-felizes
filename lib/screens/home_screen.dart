import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/screens/vacinacao_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const VacinacaoScreen()),
            );
          },
          icon: const Icon(Icons.vaccines),
          label: const Text('Abrir Vacinação'),
        ),
      ),
    );
  }
}
