import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Descobre a rota atual para setar o currentIndex
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    int currentIndex = 0;
    if (currentRoute == '/profile') {
      currentIndex = 2;
    } // Adicionar outras rotas se necessário

    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            // TODO: Implementar rota do histórico
            break;
          case 2:
            context.go('/profile');
            break;
        }
      },
    );
  }
}