// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';

// MUDANÇA 1: Convertido para ConsumerStatefulWidget para gerenciar os controllers
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers para capturar o input do usuário
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Limpa os controllers quando o widget é removido da árvore
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuta mudanças no estado de autenticação
    ref.listen(authProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // Se o usuário logou, vai para a home
          context.go('/');
        }
      });
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Gym App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Acesse sua conta',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController, // Conectado ao controller
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController, // Conectado ao controller
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  child: const Text('Acessar'),
                  onPressed: () {
                    // MUDANÇA 3: Chama o método de login usando `authProvider.notifier`
                    // e os valores dos controllers
                    ref
                        .read(authProvider.notifier)
                        .login(_emailController.text, _passwordController.text);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ainda não tem conta? ',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    TextButton(
                      child: const Text('Criar conta'),
                      onPressed: () {
                        context.go('/register');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
