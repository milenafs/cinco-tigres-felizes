import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinco_tigres_felizes/features/vaccines/domain/entities/vaccination_schedule.dart';
import 'package:cinco_tigres_felizes/features/vaccines/services/vaccine_service.dart';
import 'package:cinco_tigres_felizes/features/vaccines/presentation/widgets/vaccine_card.dart';
import 'package:cinco_tigres_felizes/features/vaccines/presentation/widgets/filter_modal.dart';

class VacinacaoScreen extends StatefulWidget {
  const VacinacaoScreen({super.key});

  @override
  State<VacinacaoScreen> createState() => _VacinacaoScreenState();
}

class _VacinacaoScreenState extends State<VacinacaoScreen> {
  String _filtroAtual = 'crianca_0_10';

  @override
  Widget build(BuildContext context) {
    final service = context.watch<VacinasService>();

    if (service.calendario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final listaFiltrada = service.calendario!.selecionarLista(_filtroAtual);
    final vacinasPendentes =
        listaFiltrada.where((v) => !service.isVacinaCompleta(v)).toList();

    final vacinasUnicas = <String, Vacina>{};
    for (final vacina in [
      ...service.calendario!.criancas,
      ...service.calendario!.adolescentes,
      ...service.calendario!.adultos,
      ...service.calendario!.gestantes,
      ...service.calendario!.idosos,
    ]) {
      vacinasUnicas.putIfAbsent(vacina.nome, () => vacina);
    }
    final vacinasConcluidas =
        vacinasUnicas.values.where((v) => service.isVacinaCompleta(v)).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vacinação'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _abrirFiltro(context),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pendentes / Calendário'),
              Tab(text: 'Vacinas Tomadas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ListaVacinas(
              vacinas: vacinasPendentes,
              service: service,
              mensagemVazia: 'Você já tomou todas as vacinas desta categoria!',
            ),
            _ListaVacinas(
              vacinas: vacinasConcluidas,
              service: service,
              mensagemVazia: 'Nenhuma vacina concluída ainda. Marque suas doses!',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirFiltro(BuildContext context) async {
    final resultado = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => FiltroModal(categoriaAtual: _filtroAtual),
    );
    if (resultado != null) setState(() => _filtroAtual = resultado);
  }
}

class _ListaVacinas extends StatelessWidget {
  const _ListaVacinas({
    required this.vacinas,
    required this.service,
    required this.mensagemVazia,
  });

  final List<Vacina> vacinas;
  final VacinasService service;
  final String mensagemVazia;

  @override
  Widget build(BuildContext context) {
    if (vacinas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            mensagemVazia,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: vacinas.length,
      itemBuilder: (context, index) {
        final vacina = vacinas[index];
        return VacinaCard(
          titulo: vacina.nome,
          descricao: vacina.descricao,
          doseTexto: vacina.doseTexto,
          statusDoses: service.obterStatusDoses(vacina),
          isCompleta: service.isVacinaCompleta(vacina),
          isEmProgresso: service.isVacinaEmProgresso(vacina),
          onDoseToggled: (i, tomada) => service.alternarDose(vacina, i, tomada),
        );
      },
    );
  }
}
