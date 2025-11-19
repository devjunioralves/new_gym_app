class Exercise {
  final String id;
  final String name;
  final String workoutType;
  final int series;
  final int reps;
  final String imageUrl;
  final String instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.workoutType,
    required this.series,
    required this.reps,
    required this.imageUrl,
    required this.instructions,
  });

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'workoutType': workoutType,
      'series': series,
      'reps': reps,
      'imageUrl': imageUrl,
      'instructions': instructions,
    };
  }

  // Criar Exercise a partir de Map (para ler do Firestore)
  factory Exercise.fromMap(Map<String, dynamic> map, String id) {
    return Exercise(
      id: id,
      name: map['name'] ?? '',
      workoutType: map['workoutType'] ?? '',
      series: map['series'] ?? 0,
      reps: map['reps'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      instructions: map['instructions'] ?? '',
    );
  }

  // Criar cópia com modificações
  Exercise copyWith({
    String? id,
    String? name,
    String? workoutType,
    int? series,
    int? reps,
    String? imageUrl,
    String? instructions,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      workoutType: workoutType ?? this.workoutType,
      series: series ?? this.series,
      reps: reps ?? this.reps,
      imageUrl: imageUrl ?? this.imageUrl,
      instructions: instructions ?? this.instructions,
    );
  }
}
