import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cinco_tigres_felizes/features/access/presentation/pages/home_page.dart';
import 'package:cinco_tigres_felizes/features/auth/presentation/pages/sign_up_page.dart';
import 'package:cinco_tigres_felizes/features/auth/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final auth = context.read<AuthProvider>();

    await auth.login(
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
        SnackBar(content: Text(auth.errorMessage ?? "Erro ao realizar login")),
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
                          Icons.health_and_safety,

                          size: 50,

                          color: Color(0xFF00897B),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Bem-vindo!",

                        textAlign: TextAlign.center,

                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Entre para continuar",

                        textAlign: TextAlign.center,

                        style: TextStyle(color: Colors.grey.shade700),
                      ),

                      const SizedBox(height: 30),

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

                      const SizedBox(height: 24),

                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return FilledButton(
                            onPressed: auth.isLoading ? null : login,

                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,

                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Entrar"),
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        },

                        child: const Text("Criar conta"),
                      ),
                    ],
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
