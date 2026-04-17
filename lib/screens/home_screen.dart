import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/screens/vacinacao_screen.dart';
import 'package:cinco_tigres_felizes/screens/hidratacao_screen.dart';
import 'lembrete_agua_screen.dart';

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 221, 221),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão Vacinação
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
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
                ),

                const SizedBox(height: 20),

                // Botão Lembrete de Água
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LembreteAguaScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Lembrete de Água'),
                  ),
                ),

                const SizedBox(height: 20),

                // Botão: Painel de Hidratação
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
