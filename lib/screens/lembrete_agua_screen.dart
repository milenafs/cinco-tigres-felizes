import 'package:flutter/material.dart';
import 'cadastro_lembrete_agua_screen.dart';
import 'visualizacao_agua_screen.dart';

class LembreteAguaScreen extends StatelessWidget {
  const LembreteAguaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes de Água')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza os botões na tela
            children: [
              SizedBox(
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
              const SizedBox(height: 20),

              // Botão para visualizar o lembrete salvo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const VisualizacaoAguaScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Visualizar lembrete salvo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ]
          )
        )
      ),
    );
  }
}