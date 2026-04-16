import 'package:flutter/material.dart';
import 'package:cinco_tigres_felizes/models/vacina_model.dart';
import 'package:cinco_tigres_felizes/services/vacinas_service.dart';
import 'package:cinco_tigres_felizes/widgets/vacina_card.dart';
import 'package:cinco_tigres_felizes/widgets/filtro_vacina.dart';

class VacinacaoScreen extends StatefulWidget {
  const VacinacaoScreen({super.key});

  @override
  State<VacinacaoScreen> createState() => _VacinacaoScreenState();
}

class _VacinacaoScreenState extends State<VacinacaoScreen> {
  String _filtroAtual = 'crianca_0_10';

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
      appBar: AppBar(
        title: const Text('Vacinação'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0), 
            child:
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () async {
                // Abre o modal e espera o resultado
                final resultado = await showModalBottomSheet<String>(
                  context: context,
                  builder: (context) => FiltroModal(categoriaAtual: _filtroAtual),
                );

                // Se o usuário selecionou algo e clicou em aplicar
                if (resultado != null) {
                  setState(() {
                    _filtroAtual = resultado;
                  });
                }
              },
            ),
          ),
        ],
      ),
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

          final calendario = snapshot.data;
          if (calendario == null) {
            return const Center(child: Text('Erro ao carregar dados.'));
          }

          // Filtra a lista a ser exibida
          List<VacinaModel> listaExibida;
          switch (_filtroAtual) {
            case 'adolescente_11_19': listaExibida = calendario.adolescentes; break;
            case 'adulto_20_59': listaExibida = calendario.adultos; break;
            case 'gestante': listaExibida = calendario.gestantes; break;
            case 'idoso_60_mais': listaExibida = calendario.idosos; break;
            default: listaExibida = calendario.criancas;
          }

          // Checa se houve algum erro
          if (listaExibida.isEmpty) {
            return const Center(child: Text('Nenhuma vacina encontrada para este grupo.'));
          }

          return ListView.builder(
            itemCount: listaExibida.length,
            itemBuilder: (context, index) {
              final vacina = listaExibida[index];
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
