import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/hydration_service.dart';

class HidratacaoScreen extends StatelessWidget {
  const HidratacaoScreen({super.key});

  void _mostrarDialogEditarMeta(BuildContext context) {
    final service = context.read<HidratacaoService>();

    final controller = TextEditingController(
      text: service.model.metaDiaria.toString(),
    );

    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text("Editar meta diária"),

        content: TextField(
          controller: controller,

          keyboardType: TextInputType.number,

          decoration: const InputDecoration(
            labelText: "Quantidade em ml",

            prefixIcon: Icon(Icons.water_drop),

            border: OutlineInputBorder(),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text("Cancelar"),
          ),

          FilledButton(
            onPressed: () {
              final valor = int.tryParse(controller.text);

              if (valor != null) {
                service.atualizarMeta(valor);
              }

              Navigator.pop(context);
            },

            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void _confirmarReset(BuildContext context) {
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text("Zerar hidratação?"),

        content: const Text("O consumo de água de hoje será zerado."),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text("Cancelar"),
          ),

          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),

            onPressed: () {
              context.read<HidratacaoService>().zerarDia();

              Navigator.pop(context);
            },

            child: const Text("Zerar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HidratacaoService>();

    final model = service.model;

    return Scaffold(
      appBar: AppBar(title: const Text("Hidratação"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),

              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  children: [
                    Text(
                      "${(model.porcentagem * 100).toInt()}%",

                      style: const TextStyle(
                        fontSize: 48,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "da meta diária",

                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 25),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),

                      child: LinearProgressIndicator(
                        value: model.porcentagem,

                        minHeight: 18,

                        backgroundColor: Colors.teal.shade100,

                        color: Colors.teal,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "${model.consumoAtual} ml / "
                      "${model.metaDiaria} ml",

                      style: const TextStyle(
                        fontSize: 20,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Faltam ${model.restante} ml",

                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: FilledButton.icon(
                onPressed: () => _mostrarDialogEditarMeta(context),

                icon: const Icon(Icons.edit),

                label: const Text("Editar meta diária"),

                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal,

                  padding: const EdgeInsets.all(16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,

              child: Text(
                "Adicionar consumo",

                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _botaoAgua(
                    titulo: "Copo",

                    quantidade: 250,

                    icone: Icons.local_drink,

                    onPressed: () =>
                        context.read<HidratacaoService>().adicionarAgua(250),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: _botaoAgua(
                    titulo: "Garrafa",

                    quantidade: 500,

                    icone: Icons.water_drop,

                    onPressed: () =>
                        context.read<HidratacaoService>().adicionarAgua(500),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            TextButton.icon(
              onPressed: () => _confirmarReset(context),

              icon: const Icon(Icons.delete_outline, color: Colors.red),

              label: const Text(
                "Zerar dia",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoAgua({
    required String titulo,

    required int quantidade,

    required IconData icone,

    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: onPressed,

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              Icon(icone, size: 40, color: Colors.teal),

              const SizedBox(height: 10),

              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),

              Text(
                "${quantidade}ml",

                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
