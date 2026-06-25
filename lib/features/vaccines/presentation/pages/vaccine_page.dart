import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinco_tigres_felizes/features/vaccines/models/vaccine_model.dart';
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<VacinaModel> listaFiltrada = service.calendario!.selecionarLista(_filtroAtual);
    List<VacinaModel> vacinasPendentes = listaFiltrada.where((v) => !service.isVacinaCompleta(v)).toList();
    
    final Map<String, VacinaModel> vacinasUnicas = {};
    for (var vacina in [
      ...service.calendario!.criancas,
      ...service.calendario!.adolescentes,
      ...service.calendario!.adultos,
      ...service.calendario!.gestantes,
      ...service.calendario!.idosos,
    ]) {
      vacinasUnicas[vacina.nome] ??= vacina; 
    }
    List<VacinaModel> todasAsVacinas = vacinasUnicas.values.toList();

    List<VacinaModel> vacinasConcluidas = todasAsVacinas.where((v) => service.isVacinaCompleta(v)).toList();

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
                onPressed: () async {
                  final resultado = await showModalBottomSheet<String>(
                    context: context,
                    builder: (context) => FiltroModal(categoriaAtual: _filtroAtual),
                  );
                  if (resultado != null) {
                    setState(() {
                      _filtroAtual = resultado;
                    });
                  }
                },
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
            _construirListaVacinas(vacinasPendentes, service, mensagemVazia: 'Você já tomou todas as vacinas desta categoria!'),
            _construirListaVacinas(vacinasConcluidas, service, mensagemVazia: 'Nenhuma vacina concluída ainda. Marque suas doses!'),
          ],
        ),
      ),
    );
  }

  Widget _construirListaVacinas(List<VacinaModel> lista, VacinasService service, {required String mensagemVazia}) {
    if (lista.isEmpty) {
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
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final vacina = lista[index];
        return VacinaCard(
          titulo: vacina.nome,
          descricao: vacina.descricao,
          
          // A ÚNICA MUDANÇA É AQUI NESSA LINHA:
          // Antes estava vacina.dose, agora é vacina.doseTexto
          doseTexto: vacina.doseTexto, 
          
          statusDoses: service.obterStatusDoses(vacina),
          isCompleta: service.isVacinaCompleta(vacina),
          isEmProgresso: service.isVacinaEmProgresso(vacina),
          onDoseToggled: (indexDose, isTomada) {
            service.alternarDose(vacina, indexDose, isTomada);
          },
        );
      },
    );
  }
}