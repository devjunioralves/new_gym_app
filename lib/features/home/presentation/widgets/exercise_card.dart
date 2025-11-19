// lib/features/home/presentation/widgets/exercise_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExerciseCard extends StatelessWidget {
  final String exerciseName;
  final String seriesReps;
  final String imageUrl;

  const ExerciseCard({
    super.key,
    required this.exerciseName,
    required this.seriesReps,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navega para a tela de detalhes usando o nome como "ID"
        context.go('/exercise/$exerciseName');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(seriesReps, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.play_arrow, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}