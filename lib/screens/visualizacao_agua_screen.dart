import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VisualizacaoAguaScreen extends StatefulWidget {
  const VisualizacaoAguaScreen({super.key});

  @override
  State<VisualizacaoAguaScreen> createState() => _VisualizacaoAguaScreenState();
}

class _VisualizacaoAguaScreenState extends State<VisualizacaoAguaScreen> {
  String _horarioExibicao = "Carregando...";

  @override
  void initState() {
    super.initState();
    _carregarHorario();
  }

  // Função para buscar o dado no armazenamento local
  Future<void> _carregarHorario() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonS = prefs.getString('horario_agua');

    if (jsonS == null) {
      setState(() => _horarioExibicao = "Nenhum lembrete cadastrado");
      return;
    }

    try {
      final Map<String, dynamic> dados = jsonDecode(jsonS);

      // Extraímos todos os campos, garantindo que os minutos existam (ou sejam 0)
      final hInicio = dados['horaInicio'] ?? 0;
      final mInicio = dados['minutoInicio'] ?? 0;
      final hFim = dados['horaFim'] ?? 0;
      final mFim = dados['minutoFim'] ?? 0;
      final freq = dados['frequencia'] ?? 0;

      // Formatamos com padLeft para garantir o 08:05 em vez de 8:5
      String formatar(int valor) => valor.toString().padLeft(2, '0');

      setState(() {
        _horarioExibicao = 
            "Das ${formatar(hInicio)}:${formatar(mInicio)} às "
            "${formatar(hFim)}:${formatar(mFim)}, "
            "a cada $freq min";
      });
    } catch (e) {
      setState(() => _horarioExibicao = "Erro ao carregar formato");
    }
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
              _horarioExibicao,
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