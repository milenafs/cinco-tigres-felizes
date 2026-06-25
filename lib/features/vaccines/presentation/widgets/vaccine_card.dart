import 'package:flutter/material.dart';

class VacinaCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String doseTexto;
  final List<bool> statusDoses;
  final bool isCompleta;
  final bool isEmProgresso;
  final Function(int index, bool isTomada) onDoseToggled;

  const VacinaCard({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.doseTexto,
    required this.statusDoses,
    required this.isCompleta,
    required this.isEmProgresso,
    required this.onDoseToggled,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica das Cores
    Color corCard = Colors.white;
    Color corBorda = Colors.transparent;
    Color corIcone = Colors.teal;

    if (isCompleta) {
      corCard = Colors.green.shade50;
      corBorda = Colors.green.shade300;
      corIcone = Colors.green;
    } else if (isEmProgresso) {
      corCard = Colors.amber.shade50;
      corBorda = Colors.amber.shade400;
      corIcone = Colors.amber.shade700;
    }

    return Card(
      color: corCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: corBorda, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.vaccines, size: 28, color: corIcone),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        descricao,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dose recomendada: $doseTexto',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meu Progresso:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: List.generate(statusDoses.length, (index) {
                    final tomada = statusDoses[index];
                    return IconButton(
                      icon: Icon(
                        tomada ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: tomada ? (isCompleta ? Colors.green : Colors.amber.shade700) : Colors.grey,
                        size: 28,
                      ),
                      onPressed: () => onDoseToggled(index, !tomada),
                      tooltip: tomada ? 'Desmarcar dose ${index + 1}' : 'Marcar dose ${index + 1}',
                    );
                  }),
                ),
              ],
            ),

            // Selos Visuais
            if (isCompleta)
              _construirSelo('Vacinação Completa', Colors.green, Icons.verified)
            else if (isEmProgresso)
              _construirSelo('Em Andamento', Colors.amber.shade700, Icons.timelapse),
          ],
        ),
      ),
    );
  }

  Widget _construirSelo(String texto, Color cor, IconData icone) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}