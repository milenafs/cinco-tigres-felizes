import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/achievements_provider.dart';
import 'package:intl/intl.dart';

class AchievementsGalleryPage extends StatelessWidget {
  const AchievementsGalleryPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final achievement = Provider.of<AchievementsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Conquistas')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: achievement.badges.length,
        itemBuilder: (context, index) {
          final badge = achievement.badges[index];
          
          return Card(
            color: badge.isDesbloqueado ? Colors.white : Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.military_tech, // Troque pelo seu badge.iconePath
                    size: 64,
                    color: badge.isDesbloqueado ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: badge.isDesbloqueado ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Critério 5: Mostrar condição se bloqueado
                    badge.isDesbloqueado 
                      // Critério 6: Mostrar data se desbloqueado
                      ? 'Conquistado em:\n${DateFormat('dd/MM/yyyy').format(badge.desbloqueadoEm!)}' 
                      : badge.descricaoCondicao,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}