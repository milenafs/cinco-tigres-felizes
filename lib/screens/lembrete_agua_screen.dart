import 'package:flutter/material.dart';
import 'cadastro_lembrete_agua_screen.dart';

class LembreteAguaScreen extends StatelessWidget {
  const LembreteAguaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes de Água')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CadastroLembreteScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar novo lembrete'),
            ),
          ),
        ),
      ),
    );
  }
}