import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/screens/vacinacao_screen.dart';
import 'package:cinco_tigres_felizes/screens/hidratacao_screen.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão de vacinação
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const VacinacaoScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.vaccines),
              label: const Text('Abrir Vacinação'),
            ),

            const SizedBox(height: 20),

            // Botão para hidratação
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HidratacaoScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.water_drop),
              label: const Text('Painel de Hidratação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
