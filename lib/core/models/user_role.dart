enum UserRole {
  student('Aluno'),
  personalTrainer('Personal Trainer');

  final String displayName;
  const UserRole(this.displayName);

  // Converter para string para salvar no Firestore
  String toFirestore() => name;

  // Criar a partir de string do Firestore
  static UserRole fromFirestore(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.student,
    );
  }

  // Verificações de permissão
  bool get isStudent => this == UserRole.student;
  bool get isPersonalTrainer => this == UserRole.personalTrainer;

  // Permissões
  bool get canCreateExercises => isPersonalTrainer;
  bool get canEditExercises => isPersonalTrainer;
  bool get canAssignExercises => isPersonalTrainer;
  bool get canViewAllStudents => isPersonalTrainer;
}
