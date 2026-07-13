import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cinco_tigres_felizes/features/access/presentation/pages/home_page.dart';
import 'package:cinco_tigres_felizes/features/auth/presentation/pages/login_page.dart';
import 'package:cinco_tigres_felizes/features/auth/providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> createAccount() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não coincidem.")));

      return;
    }

    final auth = context.read<AuthProvider>();

    await auth.signUp(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    if (auth.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? "Não foi possível criar a conta."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFF1F8E9)],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),

                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,

                      children: [
                        Container(
                          width: 90,
                          height: 90,

                          decoration: const BoxDecoration(
                            color: Color(0xFFE0F2F1),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.person_add_alt_1,

                            size: 50,

                            color: Color(0xFF00897B),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Criar conta",

                          textAlign: TextAlign.center,

                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Crie seu acesso para salvar suas informações.",

                          textAlign: TextAlign.center,

                          style: TextStyle(color: Colors.grey.shade700),
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          controller: nameController,

                          decoration: const InputDecoration(
                            labelText: "Nome completo",

                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: emailController,

                          keyboardType: TextInputType.emailAddress,

                          decoration: const InputDecoration(
                            labelText: "Email",

                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passwordController,

                          obscureText: obscurePassword,

                          decoration: InputDecoration(
                            labelText: "Senha",

                            prefixIcon: const Icon(Icons.lock_outline),

                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),

                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: confirmPasswordController,

                          obscureText: obscureConfirmPassword,

                          decoration: InputDecoration(
                            labelText: "Confirmar senha",

                            prefixIcon: const Icon(Icons.lock_reset),

                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),

                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return FilledButton(
                              onPressed: auth.isLoading ? null : createAccount,

                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text("Criar Conta"),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,

                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },

                          child: const Text("Já tenho uma conta"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
