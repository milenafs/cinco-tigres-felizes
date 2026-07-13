import 'package:flutter/material.dart';

import '../../models/habits_model.dart';

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
    final streak = habito.calcularStreak();

    final temBordaStreak = streak > 6;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: temBordaStreak
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEB3B), Color(0xFFEF5350)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildCardContent(periodos, contagemHoje),
              ),
            )
          : _buildCardContent(periodos, contagemHoje),
    );
  }

  Widget _buildCardContent(
    List<PeriodoHistorico> periodos,
    int contagemHoje,
  ) {
    return Padding(
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
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                _buildStreakSection(),
                const SizedBox(height: 12),
                _buildHistoricoSection(periodos),
              ],
            ),
          ),
          _buildTodaySection(contagemHoje),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    final streak = habito.calcularStreak();
    final maxStreak = habito.maxStreak;

    if (streak == 0 && maxStreak == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          if (streak > 6)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text('🔥', style: TextStyle(fontSize: 18)),
            ),
          Text(
            streak > 0
                ? 'Streak: $streak ${streak == 1 ? 'dia' : 'dias'}'
                : 'Streak: 0 dias',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: streak > 0 ? Colors.orange.shade800 : Colors.teal.shade700,
            ),
          ),
          if (maxStreak > streak) ...[
            const SizedBox(width: 8),
            Text(
              'Máx: $maxStreak ${maxStreak == 1 ? 'dia' : 'dias'}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ],
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
        Text(
          titulo,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
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
    final estaNaStreak = habito.estaNaStreakAtual(periodo.data);

    return GestureDetector(
      onTap: () => aoAlternarData(periodo.data),
      child: Semantics(
        label: '${periodo.label} - ${(percentual * 100).toStringAsFixed(0)}%',
        child: Container(
          width: 32,
          height: 32,
          decoration: _buildDecoracao(percentual, estaNaStreak),
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

  BoxDecoration _buildDecoracao(double percentual, bool isStreak) {
    if (percentual == 0) {
      return BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400, width: 2),
      );
    }

    if (isStreak && percentual >= 1.0) {
      // Gradiente amarelo → vermelho para dia completo na streak
      return BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEB3B), Color(0xFFEF5350)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC62828), width: 2),
      );
    }

    if (isStreak) {
      // Progresso parcial na streak: laranja → amarelo
      return BoxDecoration(
        color: Color.lerp(
          const Color(0xFFFFA726),
          const Color(0xFFFFEB3B),
          percentual,
        )!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF7043), width: 2),
      );
    }

    // Fora da streak: cores originais
    if (percentual < 1.0) {
      return BoxDecoration(
        color: Color.lerp(
          const Color.fromARGB(255, 230, 154, 78),
          const Color.fromARGB(255, 191, 255, 88),
          percentual,
        )!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color.lerp(
            const Color.fromARGB(255, 230, 154, 78),
            const Color.fromARGB(255, 191, 255, 88),
            percentual,
          )!,
          width: 2,
        ),
      );
    }

    return BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.green.shade700, width: 2),
    );
  }

  Widget _buildTodaySection(int contagemHoje) {
    final total = habito.tipo == TipoFrequenciaHabito.vezesPorDia
        ? habito.vezesPorDia
        : 1;
    final percentual = total == 0 ? 0.0 : (contagemHoje / total).clamp(0, 1);

    return Column(
      children: [
        GestureDetector(
          onTap: () => aoAlternarData(DateTime.now()),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _corOriginal(percentual.toDouble()),
              shape: BoxShape.circle,
              border: Border.all(
                color: _corBordaOriginal(percentual.toDouble()),
                width: 2,
              ),
            ),
            child: Center(child: _buildHojeContent(contagemHoje, total)),
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

  Color _corOriginal(double percentual) {
    if (percentual == 0) return Colors.grey.shade200;
    if (percentual < 1.0) {
      return Color.lerp(
        const Color.fromARGB(255, 230, 154, 78),
        const Color.fromARGB(255, 191, 255, 88),
        percentual,
      )!;
    }
    return Colors.green;
  }

  Color _corBordaOriginal(double percentual) {
    if (percentual == 0) return Colors.grey.shade400;
    if (percentual < 1.0) {
      return Color.lerp(
        const Color.fromARGB(255, 230, 154, 78),
        const Color.fromARGB(255, 191, 255, 88),
        percentual,
      )!;
    }
    return Colors.green.shade700;
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