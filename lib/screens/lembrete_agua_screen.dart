import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cadastro_lembrete_agua_screen.dart';
import 'visualizacao_agua_screen.dart';

class LembreteAguaScreen extends StatefulWidget {
  const LembreteAguaScreen({super.key});

  @override
  State<LembreteAguaScreen> createState() => _LembreteAguaScreenState();
}

class _LembreteAguaScreenState extends State<LembreteAguaScreen> {
  
  Future<void> _salvarNoBanco(dynamic resultado) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('horario_agua', resultado.toString());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lembrete salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes de Água')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // BOTÃO DE CADASTRO (Criado pelo seu colega)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // O 'await' faz o app esperar o usuário terminar o cadastro
                      final resultado = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CadastroLembreteScreen(),
                        ),
                      );

                      // Se o usuário não cancelou e retornou um dado
                      if (resultado != null) {
                        await _salvarNoBanco(resultado);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar novo lembrete'),
                  ),
                ),

                const SizedBox(height: 20),

                // O SEU BOTÃO DE VISUALIZAÇÃO
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
                    label: const Text('Ver meu lembrete salvo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
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