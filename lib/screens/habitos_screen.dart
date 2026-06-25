import 'package:flutter/material.dart';

import '../models/habitos_model.dart';
import '../services/habitos_service.dart';
import '../widgets/habitos_card.dart';
import 'habitos_form_screen.dart';

class HabitosScreen extends StatefulWidget {
  const HabitosScreen({super.key});

  @override
  State<HabitosScreen> createState() => _HabitosScreenState();
}

class _HabitosScreenState extends State<HabitosScreen> {
  final HabitoService _servico = HabitoService();
  final List<HabitoModel> _habitos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHabitos();
  }

  Future<void> _carregarHabitos() async {
    final lista = await _servico.carregarHabitos();
    if (!mounted) {
      return;
    }
    setState(() {
      _habitos.clear();
      _habitos.addAll(lista);
      _carregando = false;
    });
  }

  Future<void> _abrirFormularioHabito() async {
    final novoHabito = await Navigator.of(context).push<HabitoModel>(
      MaterialPageRoute(
        builder: (_) => const FormularioHabitoScreen(),
      ),
    );
    if (novoHabito != null) {
      await _servico.adicionarHabito(novoHabito);
      setState(() {
        _habitos.insert(0, novoHabito);
      });
    }
  }

  Future<void> _alternarConclusao(HabitoModel habito, DateTime data) async {
    await _servico.alternarConclusao(habito.id, data);
    await _carregarHabitos();
  }

  Future<void> _editarHabito(HabitoModel habito) async {
    final habitoAtualizado = await Navigator.of(context).push<HabitoModel>(
      MaterialPageRoute(
        builder: (_) => FormularioHabitoScreen(habito: habito),
      ),
    );
    if (habitoAtualizado != null) {
      await _servico.atualizarHabito(habitoAtualizado);
      await _carregarHabitos();
    }
  }

  Future<void> _removerHabito(HabitoModel habito) async {
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
      await _servico.removerHabito(habito.id);
      await _carregarHabitos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hábitos')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.all(20),
              child: _habitos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Nenhum hábito encontrado.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _abrirFormularioHabito,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar hábito'),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      itemCount: _habitos.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final habito = _habitos[index];
                        return CartaoHabito(
                          habito: habito,
                          aoAlternarData: (data) => _alternarConclusao(habito, data),
                          aoEditar: () => _editarHabito(habito),
                          aoRemover: () => _removerHabito(habito),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioHabito,
        tooltip: 'Adicionar hábito',
        child: const Icon(Icons.add),
      ),
    );
  }
}
