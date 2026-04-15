import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisualizacaoAguaScreen extends StatefulWidget {
  const VisualizacaoAguaScreen({super.key});

  @override
  State<VisualizacaoAguaScreen> createState() => _VisualizacaoAguaScreenState();
}

class _VisualizacaoAguaScreenState extends State<VisualizacaoAguaScreen> {
  String _horarioSalvo = "Carregando...";

  @override
  void initState() {
    super.initState();
    _carregarHorario();
  }

  // Função isolada para buscar o dado no armazenamento local
  Future<void> _carregarHorario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _horarioSalvo = prefs.getString('horario_agua') ?? "Nenhum horário cadastrado";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Lembrete'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.water_drop_outlined,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 30),
            const Text(
              'Próxima hidratação programada:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              _horarioSalvo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: _carregarHorario,
              child: const Text('Atualizar Visualização'),
            ),
          ],
        ),
      ),
    );
  }
}