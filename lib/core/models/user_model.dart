import 'package:new_gym_app/core/models/user_role.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final UserRole role;
  final String?
  personalTrainerId; // ID do personal responsável (apenas para alunos)

  const User({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.role,
    this.personalTrainerId,
  });

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role.toFirestore(),
      'personalTrainerId': personalTrainerId,
    };
  }

  // Criar User a partir de Map (para ler do Firestore)
  factory User.fromMap(Map<String, dynamic> map, String uid) {
    return User(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? 'assets/images/profile.png',
      role: UserRole.fromFirestore(map['role'] ?? 'student'),
      personalTrainerId: map['personalTrainerId'],
    );
  }

  // Criar cópia com modificações
  User copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    UserRole? role,
    String? personalTrainerId,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      personalTrainerId: personalTrainerId ?? this.personalTrainerId,
    );
  }

  // Helpers de permissão
  bool get isStudent => role.isStudent;
  bool get isPersonalTrainer => role.isPersonalTrainer;
  bool get canCreateExercises => role.canCreateExercises;
  bool get canEditExercises => role.canEditExercises;
  bool get canAssignExercises => role.canAssignExercises;
}
