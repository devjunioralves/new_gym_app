import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gym_app/app.dart';

// import 'package:new_gym_app/core/utils/init_firestore.dart';

import 'firebase_options.dart';

// Descomente a linha abaixo e a chamada no main() para popular o banco pela primeira vez

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ⚠️ ATENÇÃO: Descomente a linha abaixo apenas UMA VEZ para popular o banco de dados
  // Após a primeira execução, comente novamente para evitar duplicação

  // await initializeFirestoreData();

  runApp(const ProviderScope(child: GymApp()));
}
