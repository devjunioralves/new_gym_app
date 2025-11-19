enum UserRole {
  student('Aluno'),
  personalTrainer('Personal Trainer');

  final String displayName;
  const UserRole(this.displayName);

  String toFirestore() => name;

  static UserRole fromFirestore(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.student,
    );
  }

  bool get isStudent => this == UserRole.student;
  bool get isPersonalTrainer => this == UserRole.personalTrainer;

  bool get canCreateExercises => isPersonalTrainer;
  bool get canEditExercises => isPersonalTrainer;
  bool get canAssignExercises => isPersonalTrainer;
  bool get canViewAllStudents => isPersonalTrainer;
}
