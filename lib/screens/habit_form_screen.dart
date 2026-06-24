import 'package:flutter/material.dart';

import '../models/habit_model.dart';

class FormularioHabitoScreen extends StatefulWidget {
  const FormularioHabitoScreen({super.key});

  @override
  State<FormularioHabitoScreen> createState() => _FormularioHabitoState();
}

class _FormularioHabitoState extends State<FormularioHabitoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _vezesController = TextEditingController(text: '1');
  final _diaDoMesController = TextEditingController();

  TipoFrequenciaHabito _tipo = TipoFrequenciaHabito.diario;
  final List<bool> _diasDaSemanaSelecionados = List<bool>.filled(7, false);

  @override
  void dispose() {
    _nomeController.dispose();
    _vezesController.dispose();
    _diaDoMesController.dispose();
    super.dispose();
  }

  void _salvarHabito() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tipo == TipoFrequenciaHabito.diasDaSemana &&
        !_diasDaSemanaSelecionados.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um dia da semana.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nome = _nomeController.text.trim();
    final vezesPorDia = int.tryParse(_vezesController.text) ?? 1;
    final diaDoMes = int.tryParse(_diaDoMesController.text);

    final habito = HabitoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      tipo: _tipo,
      vezesPorDia: vezesPorDia,
      diasDaSemana: _diasDaSemanaSelecionados
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => entry.key + 1)
          .toList(),
      diaDoMes: _tipo == TipoFrequenciaHabito.mensal ? diaDoMes : null,
    );

    Navigator.of(context).pop(habito);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo hábito')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do hábito',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe um nome para o hábito.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoFrequenciaHabito>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de frequência',
                  border: OutlineInputBorder(),
                ),
                items: TipoFrequenciaHabito.values.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(rotuloFrequencia(option)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tipo = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_tipo == TipoFrequenciaHabito.vezesPorDia) ...[
                TextFormField(
                  controller: _vezesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Vezes por dia',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final numero = int.tryParse(value ?? '');
                    if (numero == null || numero <= 0) {
                      return 'Informe uma quantidade válida.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (_tipo == TipoFrequenciaHabito.diasDaSemana) ...[
                const Text('Selecione os dias da semana'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List<Widget>.generate(7, (index) {
                    final label = rotuloDiaSemana(index + 1);
                    return ChoiceChip(
                      label: Text(label),
                      selected: _diasDaSemanaSelecionados[index],
                      onSelected: (selected) {
                        setState(() {
                          _diasDaSemanaSelecionados[index] = selected;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
              if (_tipo == TipoFrequenciaHabito.mensal) ...[
                TextFormField(
                  controller: _diaDoMesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Dia do mês',
                    hintText: 'Ex: 15',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe um dia do mês.';
                    }
                    final numero = int.tryParse(value);
                    if (numero == null || numero < 1 || numero > 31) {
                      return 'Informe um dia do mês válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: _salvarHabito,
                icon: const Icon(Icons.save),
                label: const Text('Salvar hábito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
