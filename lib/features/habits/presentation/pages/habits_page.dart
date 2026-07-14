import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habits_model.dart';
import '../../providers/habitos_provider.dart';
import '../widgets/habitos_card.dart';
import 'habits_form_page.dart';

import '../../../achievements/presentation/pages/gallery_page.dart'; 

class HabitosScreen extends StatelessWidget {
  const HabitosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hábitos'),
        // 2. Adicionamos o botão de conquistas aqui
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech, color: Colors.amber, size: 28),
            tooltip: 'Ver Conquistas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AchievementsGalleryPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8), // Um pequeno espaço para não colar na borda
        ],
      ),
      body: Consumer<HabitosProvider>(
        builder: (context, provider, _) {
          if (provider.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.erro != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.erro!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.carregarHabitos(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.habitos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nenhum hábito encontrado.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _abrirFormularioHabito(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar hábito'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.separated(
              itemCount: provider.habitos.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final habito = provider.habitos[index];
                return CartaoHabito(
                  habito: habito,
                  aoAlternarData: (data) =>
                      _alternarConclusao(context, habito, data),
                  aoEditar: () => _editarHabito(context, habito),
                  aoRemover: () => _removerHabito(context, habito),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioHabito(context),
        tooltip: 'Adicionar hábito',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _abrirFormularioHabito(BuildContext context) async {
    final provider = context.read<HabitosProvider>();
    final novoHabito = await Navigator.of(context).push<HabitoModel>(
      MaterialPageRoute(builder: (_) => const FormularioHabitoScreen()),
    );
    if (novoHabito != null) {
      await provider.adicionarHabito(novoHabito);
    }
  }

  void _alternarConclusao(
    BuildContext context,
    HabitoModel habito,
    DateTime data,
  ) {
    // Atualização otimista: a UI reage imediatamente
    context.read<HabitosProvider>().alternarConclusao(habito.id, data);
  }

  Future<void> _editarHabito(
    BuildContext context,
    HabitoModel habito,
  ) async {
    final provider = context.read<HabitosProvider>();
    final habitoAtualizado = await Navigator.of(context).push<HabitoModel>(
      MaterialPageRoute(
        builder: (_) => FormularioHabitoScreen(habito: habito),
      ),
    );
    if (habitoAtualizado != null) {
      await provider.atualizarHabito(habitoAtualizado);
    }
  }

  Future<void> _removerHabito(
    BuildContext context,
    HabitoModel habito,
  ) async {
    final provider = context.read<HabitosProvider>();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover hábito'),
          content: const Text('Tem certeza que deseja remover este hábito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      await provider.removerHabito(habito.id);
    }
  }
}