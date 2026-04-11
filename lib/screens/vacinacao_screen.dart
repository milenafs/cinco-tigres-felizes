import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/models/vacina_model.dart';
import 'package:cinco_tigres_felizes/services/vacinas_service.dart';
import 'package:cinco_tigres_felizes/widgets/vacina_card.dart';

class VacinacaoScreen extends StatefulWidget {
  const VacinacaoScreen({super.key});

  @override
  State<VacinacaoScreen> createState() => _VacinacaoScreenState();
}

class _VacinacaoScreenState extends State<VacinacaoScreen> {
  late final VacinasService _vacinasService;
  late final Future<VacinasCalendarioModel> _vacinasFuture;

  @override
  void initState() {
    super.initState();
    _vacinasService = VacinasService();
    _vacinasFuture = _vacinasService.carregarVacinas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vacinação')),
      body: FutureBuilder<VacinasCalendarioModel>(
        future: _vacinasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Erro ao carregar vacinas: ${snapshot.error}'),
              ),
            );
          }

          final vacinas = snapshot.data;
          if (vacinas == null || vacinas.criancas.isEmpty) {
            return const Center(
              child: Text('Nenhuma vacina encontrada para criancas.'),
            );
          }

          // TODO: filtrar a lista de vacinas com base na faixa etaria selecionada. Cria um widget de filtro no widgets/
          return ListView.builder(
            itemCount: vacinas.criancas.length,
            itemBuilder: (context, index) {
              final vacina = vacinas.criancas[index];
              return VacinaCard(
                titulo: vacina.nome,
                descricao: vacina.descricao,
                dose: vacina.dose,
              );
            },
          );
        },
      ),
    );
  }
}
