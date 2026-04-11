import 'package:flutter/material.dart';

class FiltroModal extends StatefulWidget {
  final String categoriaAtual;

  const FiltroModal({super.key, required this.categoriaAtual});

  @override
  State<FiltroModal> createState() => _FiltroModalState();
}

class _FiltroModalState extends State<FiltroModal> {
  late String _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _categoriaSelecionada = widget.categoriaAtual;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtrar Vacinação', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          DropdownButtonFormField<String>(
            value: _categoriaSelecionada,
            decoration: const InputDecoration(labelText: 'Selecione sua faixa etária'),
            items: const [
              DropdownMenuItem(value: 'crianca_0_10', child: Text('Criança (0 a 10 anos)')),
              DropdownMenuItem(value: 'adolescente_11_19', child: Text('Adolescente (11 a 19 anos)')),
              DropdownMenuItem(value: 'adulto_20_59', child: Text('Adulto (20 a 59 anos)')),
              DropdownMenuItem(value: 'gestante', child: Text('Gestante')),
              DropdownMenuItem(value: 'idoso_60_mais', child: Text('Idoso (60+ anos)')),
            ],
            onChanged: (val) => setState(() => _categoriaSelecionada = val!),
          ),
          
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _categoriaSelecionada),
              child: const Text('Aplicar Filtro'),
            ),
          )
        ],
      ),
    );
  }
}