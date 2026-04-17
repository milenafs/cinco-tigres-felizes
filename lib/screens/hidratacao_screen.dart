import 'package:flutter/material.dart';
import '../models/hidratacao_model.dart';

class HidratacaoScreen extends StatefulWidget {
  const HidratacaoScreen({super.key});

  @override
  State<HidratacaoScreen> createState() => _HidratacaoScreenState();
}

class _HidratacaoScreenState extends State<HidratacaoScreen> {
  // Dados iniciais
  int _consumoAtual = 0;
  final int _metaDiaria = 2000;

  void _adicionarAgua(int quantidade) {
    setState(() {
      _consumoAtual += quantidade;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = HidratacaoModel(
      metaDiaria: _metaDiaria,
      consumoAtual: _consumoAtual,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Hidratação'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // A porcentagem
          Text(
            '${(model.porcentagem * 100).toInt()}%',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text('da meta atingida'),

          // Barra de progresso
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: LinearProgressIndicator(
              value: model.porcentagem,
              minHeight: 20,
              backgroundColor: Colors.blue.shade100,
              color: Colors.blue,
            ),
          ),

          Text('Faltam ${model.restante} ml para atingir a meta'),

          const Spacer(),
        ],
      ),
    );
  }
}
