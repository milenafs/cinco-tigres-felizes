import 'package:flutter/material.dart';

import '../models/habitos_model.dart';

class CartaoHabito extends StatelessWidget {
  final HabitoModel habito;
  final ValueChanged<DateTime> aoAlternarData;
  final VoidCallback? aoEditar;
  final VoidCallback? aoRemover;

  const CartaoHabito({
    super.key,
    required this.habito,
    required this.aoAlternarData,
    this.aoEditar,
    this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final periodos = habito.obterPeriodosHistorico();
    final hoje = DateTime.now();
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          habito.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: aoEditar,
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Editar hábito',
                      ),
                      IconButton(
                        onPressed: aoRemover,
                        icon: const Icon(Icons.delete_forever, size: 20),
                        tooltip: 'Remover hábito',
                        color: Colors.red.shade700,
                      ),
                    ],
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
            _buildTodaySection(contagemHoje),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricoSection(List<PeriodoHistorico> periodos) {
    final titulo = habito.tipo == TipoFrequenciaHabito.vezesPorDia
        ? 'Últimos 7 dias (${habito.vezesPorDia}x)'
        : 'Últimos 7 dias';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: periodos.map((periodo) => _buildPeriodoWidget(periodo)).toList(),
        ),
      ],
    );
  }

  Widget _buildPeriodoWidget(PeriodoHistorico periodo) {
    final percentual = periodo.percentual;

    return GestureDetector(
      onTap: () => aoAlternarData(periodo.data),
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
    if (percentual < 1.0) {
      return Color.lerp(const Color.fromARGB(255, 230, 154, 78), const Color.fromARGB(255, 191, 255, 88), percentual)!;
    }
    return Colors.green;
  }

  Color _corBorda(double percentual) {
    if (percentual == 0) return Colors.grey.shade400;
    if (percentual < 1.0) {
      return Color.lerp(const Color.fromARGB(255, 230, 154, 78), const Color.fromARGB(255, 191, 255, 88), percentual)!;
    }
    return Colors.green.shade700;
  }

  Widget _buildTodaySection(int contagemHoje) {
    final total = habito.tipo == TipoFrequenciaHabito.vezesPorDia ? habito.vezesPorDia : 1;
    final percentual = total == 0 ? 0.0 : (contagemHoje / total).clamp(0, 1);

    return Column(
      children: [
        GestureDetector(
          onTap: () => aoAlternarData(DateTime.now()),
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
      return Icon(
        contagem > 0 ? Icons.check : Icons.add,
        color: contagem > 0 ? Colors.white : Colors.grey.shade700,
        size: 20,
      );
    }

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
