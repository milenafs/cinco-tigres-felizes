import 'package:flutter/material.dart';

import '../../models/habits_model.dart';

class FormularioHabitoScreen extends StatefulWidget {
  final HabitoModel? habito;

  const FormularioHabitoScreen({super.key, this.habito});

  @override
  State<FormularioHabitoScreen> createState() => _FormularioHabitoState();
}

class _FormularioHabitoState extends State<FormularioHabitoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _vezesController = TextEditingController(text: '1');

  late TipoFrequenciaHabito _tipo;

  bool get _ehEdicao => widget.habito != null;

  @override
  void initState() {
    super.initState();
    _tipo = widget.habito?.tipo ?? TipoFrequenciaHabito.diario;
    _nomeController.text = widget.habito?.nome ?? '';
    _vezesController.text = widget.habito?.vezesPorDia.toString() ?? '1';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _vezesController.dispose();
    super.dispose();
  }

  void _salvarHabito() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nome = _nomeController.text.trim();
    final vezesPorDia = int.tryParse(_vezesController.text) ?? 1;

    final habito = widget.habito != null
        ? widget.habito!.copyWith(nome: nome)
        : HabitoModel(
            id:
                widget.habito?.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            nome: nome,
            tipo: _tipo,
            vezesPorDia: vezesPorDia,
            historico: widget.habito?.historico ?? {},
          );

    Navigator.of(context).pop(habito);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habito == null ? 'Novo hábito' : 'Editar hábito'),
      ),
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
              if (!_ehEdicao) ...[
                DropdownButtonFormField<TipoFrequenciaHabito>(
                  initialValue: _tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de frequência',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: TipoFrequenciaHabito.diario,
                      child: Text('Diário'),
                    ),
                    DropdownMenuItem(
                      value: TipoFrequenciaHabito.vezesPorDia,
                      child: Text('X vezes por dia'),
                    ),
                  ],
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
              ] else ...[
                TextFormField(
                  controller: TextEditingController(
                    text: _tipo == TipoFrequenciaHabito.diario
                        ? 'Diário'
                        : 'X vezes por dia',
                  ),
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de frequência',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_tipo == TipoFrequenciaHabito.vezesPorDia) ...[
                  TextFormField(
                    controller: TextEditingController(
                      text: _vezesController.text,
                    ),
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Vezes por dia',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
