import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/hydration_service.dart';

class HidratacaoScreen extends StatelessWidget {
  const HidratacaoScreen({super.key});

  // Função para exibir a caixinha pop-up de edição
  void _mostrarDialogEditarMeta(BuildContext context) {
    final service = context.read<HidratacaoService>();
    final TextEditingController controller = TextEditingController(
      text: service.model.metaDiaria.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Meta Diária'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nova meta em ml',
              hintText: 'Ex: 2500',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final novaMeta = int.tryParse(controller.text);
                if (novaMeta != null) {
                  service.atualizarMeta(novaMeta);
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HidratacaoService>();
    final model = service.model;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Hidratação'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            '${(model.porcentagem * 100).toInt()}%',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text('da meta atingida'),

          Padding(
            padding: const EdgeInsets.all(30.0),
            child: LinearProgressIndicator(
              value: model.porcentagem,
              minHeight: 20,
              backgroundColor: Colors.blue.shade100,
              color: Colors.blue,
            ),
          ),

          Text(
            'Faltam ${model.restante} ml para atingir a meta de ${model.metaDiaria} ml',
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 30), // Espaçamento antes do novo botão

          // Botão para editar meta diária
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogEditarMeta(context),
            icon: const Icon(Icons.edit),
            label: const Text(
              'Editar meta diária',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Fundo azul
              foregroundColor: Colors.white, // Texto e ícone brancos
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _botaoAgua(
                titulo: 'Copo',
                quantidade: 250,
                icone: Icons.local_drink,
                onPressed: () => context.read<HidratacaoService>().adicionarAgua(250),
              ),
              _botaoAgua(
                titulo: 'Garrafa',
                quantidade: 500,
                icone: Icons.opacity,
                onPressed: () => context.read<HidratacaoService>().adicionarAgua(500),
              ),
            ],
          ),

          const SizedBox(height: 20),

          TextButton.icon(
            onPressed: () => context.read<HidratacaoService>().zerarDia(),
            icon: const Icon(Icons.refresh, color: Colors.red),
            label: const Text('Zerar Dia', style: TextStyle(color: Colors.red)),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _botaoAgua({
    required String titulo,
    required int quantidade,
    required IconData icone,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icone),
      label: Text('$titulo\n${quantidade}ml', textAlign: TextAlign.center),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}