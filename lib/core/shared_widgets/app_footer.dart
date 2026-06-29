import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/features/auth/presentation/providers/auth_provider.dart';

class AppFooter extends ConsumerWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPersonal = user?.isPersonalTrainer ?? true;

    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    int currentIndex = 0;
    if (isPersonal) {
      if (currentRoute.startsWith('/students') ||
          currentRoute.startsWith('/student-detail') ||
          currentRoute.startsWith('/register-student')) {
        currentIndex = 1;
      } else if (currentRoute == '/profile') {
        currentIndex = 2;
      }
    } else {
      if (currentRoute.startsWith('/anamnesis')) {
        currentIndex = 1;
      } else if (currentRoute == '/profile') {
        currentIndex = 2;
      }
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(isPersonal ? Icons.group : Icons.assignment_outlined),
          label: isPersonal ? 'Alunos' : 'Anamnese',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
          case 1:
            context.go(isPersonal ? '/students' : '/anamnesis-list');
          case 2:
            context.go('/profile');
        }
      },
    );
  }
}
