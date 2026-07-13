import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';

class FiltroModal extends StatefulWidget {
  final CategoriaVacina categoriaAtual;

  const FiltroModal({super.key, required this.categoriaAtual});

  @override
  State<FiltroModal> createState() => _FiltroModalState();
}

class _FiltroModalState extends State<FiltroModal> {
  late CategoriaVacina _categoriaSelecionada;

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
          const Text(
            'Filtrar Vacinação',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<CategoriaVacina>(
            initialValue: _categoriaSelecionada,
            decoration: const InputDecoration(
              labelText: 'Selecione sua faixa etária',
            ),
            items: const [
              DropdownMenuItem(
                value: CategoriaVacina.crianca,
                child: Text('Criança (0 a 10 anos)'),
              ),
              DropdownMenuItem(
                value: CategoriaVacina.adolescente,
                child: Text('Adolescente (11 a 19 anos)'),
              ),
              DropdownMenuItem(
                value: CategoriaVacina.adulto,
                child: Text('Adulto (20 a 59 anos)'),
              ),
              DropdownMenuItem(
                value: CategoriaVacina.gestante,
                child: Text('Gestante'),
              ),
              DropdownMenuItem(
                value: CategoriaVacina.idoso,
                child: Text('Idoso (60+ anos)'),
              ),
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
          ),
        ],
      ),
    );
  }
}
