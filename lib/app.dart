// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gym_app/core/config/app_router.dart';
import 'package:new_gym_app/core/config/app_theme.dart';

class GymApp extends ConsumerWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta o provider do roteador
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Gym App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // Configuração do go_router
      routerConfig: router,
    );
  }
}