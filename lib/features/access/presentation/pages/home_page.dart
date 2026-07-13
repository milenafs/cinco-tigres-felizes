import 'package:flutter/material.dart';

import 'package:cinco_tigres_felizes/features/vaccines/presentation/pages/vaccine_page.dart';
import 'package:cinco_tigres_felizes/features/habits/presentation/pages/hydration_page.dart';
import 'package:cinco_tigres_felizes/features/habits/presentation/pages/habits_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    final nome =
        user?.displayName ?? user?.email?.split('@').first ?? 'Usuário';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Olá, $nome 👋",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Cuide da sua saúde todos os dias",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            _HomeCard(
              title: "Vacinação",
              subtitle: "Acompanhe suas vacinas",
              icon: Icons.vaccines,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VacinacaoScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            _HomeCard(
              title: "Hábitos",
              subtitle: "Organize sua rotina",
              icon: Icons.check_circle_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HabitosScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _HomeCard(
              title: "Hidratação",
              subtitle: "Controle seu consumo diário",
              icon: Icons.local_drink,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HidratacaoScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Row(
            children: [
              CircleAvatar(
                radius: 28,

                backgroundColor: Theme.of(context).colorScheme.primaryContainer,

                child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(subtitle),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
