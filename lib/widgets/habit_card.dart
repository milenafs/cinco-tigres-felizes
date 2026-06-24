import 'package:flutter/material.dart';

import '../models/habit_model.dart';

class CartaoHabito extends StatelessWidget {
  final HabitoModel habito;
  final ValueChanged<DateTime> aoAlternarData;

  const CartaoHabito({
    super.key,
    required this.habito,
    required this.aoAlternarData,
  });

  @override
  Widget build(BuildContext context) {
    final periodos = habito.obterPeriodosHistorico();
    final hoje = DateTime.now();
    final concluidoHoje = habito.estaConcluidoEm(hoje);
    final contagemHoje = habito.obterContagem(hoje);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habito.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    habito.frequenciaTexto,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHistoricoSection(periodos),
                ],
              ),
            ),
            _buildTodaySection(concluidoHoje, contagemHoje),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricoSection(List<PeriodoHistorico> periodos) {
    String titulo = '';
    switch (habito.tipo) {
      case TipoFrequenciaHabito.diario:
        titulo = 'Últimos 7 dias';
        break;
      case TipoFrequenciaHabito.vezesPorDia:
        titulo = 'Últimos 7 dias (${habito.vezesPorDia}x)';
        break;
      case TipoFrequenciaHabito.diasDaSemana:
        titulo = 'Esta semana';
        break;
      case TipoFrequenciaHabito.semanal:
        titulo = 'Últimas 7 semanas';
        break;
      case TipoFrequenciaHabito.mensal:
        titulo = 'Últimos 12 meses';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: periodos
              .map((periodo) => _buildPeriodoWidget(periodo))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPeriodoWidget(PeriodoHistorico periodo) {
    final percentual = periodo.percentual;
    final podeMarcar = periodo.podeMarcar && (habito.tipo != TipoFrequenciaHabito.mensal);

    return GestureDetector(
      onTap: podeMarcar ? () => aoAlternarData(periodo.data) : null,
      child: Semantics(
        label: '${periodo.label} - ${(percentual * 100).toStringAsFixed(0)}%',
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _cor(percentual),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _corBorda(percentual),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              periodo.label,
              style: TextStyle(
                color: percentual > 0.5 ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Color _cor(double percentual) {
    if (percentual == 0) return Colors.grey.shade200;
    if (percentual < 0.5) return Colors.orange.shade200;
    if (percentual < 1.0) return Colors.yellow.shade300;
    return Colors.green;
  }

  Color _corBorda(double percentual) {
    if (percentual == 0) return Colors.grey.shade400;
    if (percentual < 0.5) return Colors.orange.shade400;
    if (percentual < 1.0) return Colors.yellow.shade600;
    return Colors.green.shade700;
  }

  Widget _buildTodaySection(bool concluidoHoje, int contagemHoje) {
    final total = habito.tipo == TipoFrequenciaHabito.vezesPorDia ? habito.vezesPorDia : 1;
    final percentual = total == 0 ? 0.0 : (contagemHoje / total).clamp(0, 1);

    return Column(
      children: [
        GestureDetector(          key: Key('botao-marcar-hoje-${habito.id}'),          onTap: () => aoAlternarData(DateTime.now()),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _cor(percentual.toDouble()),
              shape: BoxShape.circle,
              border: Border.all(
                color: _corBorda(percentual.toDouble()),
                width: 2,
              ),
            ),
            child: Center(
              child: _buildHojeContent(contagemHoje, total),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hoje',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHojeContent(int contagem, int total) {
    if (total == 1) {
      // Diário: mostrar ícone
      return Icon(
        contagem > 0 ? Icons.check : Icons.add,
        color: contagem > 0 ? Colors.white : Colors.grey.shade700,
        size: 20,
      );
    } else {
      // X vezes por dia: mostrar contador
      return Text(
        '$contagem/$total',
        style: TextStyle(
          color: contagem > 0 ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      );
    }
  }
}
