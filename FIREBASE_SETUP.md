# Guia de Integração Firebase - new_gym_app

## ✅ O que foi implementado

Seu projeto foi totalmente integrado com Firebase! As seguintes mudanças foram feitas:

### 📁 Novos Arquivos Criados

1. **`lib/core/services/firebase_auth_service.dart`**

   - Gerencia autenticação (login, registro, logout, atualização de perfil)
   - Integração com Firebase Authentication e Firestore

2. **`lib/core/services/firebase_exercise_service.dart`**

   - CRUD completo de exercícios no Firestore
   - Método para popular banco com dados iniciais

3. **`lib/core/utils/init_firestore.dart`**
   - Script para inicializar o banco de dados

### 🔄 Arquivos Atualizados

1. **`lib/core/models/user_model.dart`**

   - Adicionado `toMap()` e `fromMap()` para conversão Firestore
   - Adicionado `copyWith()` para manipulação imutável

2. **`lib/core/models/exercise_model.dart`**

   - Adicionado `toMap()` e `fromMap()` para conversão Firestore
   - Adicionado `copyWith()` para manipulação imutável

3. **`lib/features/auth/presentation/providers/auth_provider.dart`**

   - Substituído dados mockados por Firebase Authentication
   - Implementado `authStateProvider` com Stream
   - Tratamento de erros melhorado

4. **`lib/features/exercise_detail/presentation/providers/exercise_provider.dart`**

   - Substituído repository fake por Firebase Firestore
   - Adicionado provider por categoria com Stream

5. **`lib/main.dart`**
   - Configurado inicialização do Firebase
   - Comentários para popular banco de dados

## 🚀 Configuração do Firebase

### Passo 1: Instalar FlutterFire CLI

```powershell
dart pub global activate flutterfire_cli
```

### Passo 2: Configurar Firebase

```powershell
flutterfire configure
```

Este comando irá:

- Criar um projeto Firebase (ou usar um existente)
- Gerar o arquivo `firebase_options.dart` com suas credenciais
- Configurar Firebase para todas as plataformas

### Passo 3: Configurar Regras de Segurança no Firestore

Acesse o [Firebase Console](https://console.firebase.google.com/):

1. Vá em **Firestore Database** → **Regras**
2. Cole as seguintes regras:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Regras para usuários
    match /users/{userId} {
      // Permite leitura e escrita apenas para o próprio usuário
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Regras para exercícios
    match /exercises/{exerciseId} {
      // Qualquer usuário autenticado pode ler
      allow read: if request.auth != null;
      // Apenas admins podem criar/atualizar/deletar (ajuste conforme necessário)
      allow write: if request.auth != null;
    }
  }
}
```

### Passo 4: Habilitar Authentication

No Firebase Console:

1. Vá em **Authentication** → **Sign-in method**
2. Habilite **Email/Password**

### Passo 5: Popular o Banco de Dados

No arquivo `lib/main.dart`, **descomente** estas linhas:

```dart
import 'package:new_gym_app/core/utils/init_firestore.dart';

// ...e dentro do main():
await initializeFirestoreData();
```

Execute o app **UMA VEZ** para popular o banco, depois **comente novamente** para evitar duplicação.

## 📊 Estrutura do Firestore

```
firestore/
├── users/
│   └── {userId}/
│       ├── name: string
│       ├── email: string
│       ├── photoUrl: string
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
└── exercises/
    └── {exerciseId}/
        ├── name: string
        ├── workoutType: string
        ├── series: number
        ├── reps: number
        ├── imageUrl: string
        └── instructions: string
```

## 🔑 Principais Mudanças no Código

### AuthProvider

**Antes (Mockado):**

```dart
Future<void> login(String email, String password) async {
  await Future.delayed(const Duration(seconds: 1));
  state = User(uid: '123', name: 'John Doe', email: email, ...);
}
```

**Depois (Firebase):**

```dart
Future<void> login(String email, String password) async {
  final authService = ref.read(firebaseAuthServiceProvider);
  final user = await authService.login(email, password);
  state = AsyncValue.data(user);
}
```

### ExerciseProvider

**Antes (Mockado):**

```dart
final _exercises = [Exercise(...), Exercise(...)];
Future<List<Exercise>> getAllExercises() async {
  return _exercises;
}
```

**Depois (Firebase):**

```dart
Future<List<Exercise>> getAllExercises() async {
  final snapshot = await _firestore.collection('exercises').get();
  return snapshot.docs.map((doc) => Exercise.fromMap(doc.data(), doc.id)).toList();
}
```

## 🎯 Funcionalidades Disponíveis

### Autenticação

- ✅ Login com email/senha
- ✅ Registro de novos usuários
- ✅ Logout
- ✅ Atualização de perfil
- ✅ Stream de autenticação (auto-login)
- ✅ Tratamento de erros do Firebase

### Exercícios

- ✅ Listar todos os exercícios
- ✅ Buscar por nome
- ✅ Filtrar por categoria (Stream)
- ✅ Adicionar novos exercícios
- ✅ Atualizar exercícios
- ✅ Deletar exercícios

## 🧪 Testando a Integração

### 1. Teste de Autenticação

```dart
// Login
await ref.read(authProvider.notifier).login('teste@email.com', 'senha123');

// Verificar usuário atual
final user = ref.watch(currentUserProvider);
print(user?.name); // Deve mostrar o nome do usuário
```

### 2. Teste de Exercícios

```dart
// Buscar todos os exercícios
final exercises = await ref.read(exerciseListProvider.future);
print('Total de exercícios: ${exercises.length}');

// Buscar por categoria
final peitoExercises = ref.watch(exercisesByCategoryProvider('Peito'));
```

## 🛠️ Próximos Passos Recomendados

1. **Histórico de Treinos**

   - Criar collection `workouts` para salvar treinos do usuário
   - Relacionar com `userId` e data

2. **Upload de Imagens**

   - Integrar Firebase Storage para imagens de exercícios
   - Permitir usuários fazerem upload de foto de perfil

3. **Notificações**

   - Firebase Cloud Messaging para lembretes de treino

4. **Analytics**

   - Firebase Analytics para rastrear uso do app

5. **Offline Support**
   - Firestore já tem cache offline por padrão
   - Configurar persistence se necessário

## 📝 Comandos Úteis

```powershell
# Instalar dependências
flutter pub get

# Configurar Firebase
flutterfire configure

# Executar app
flutter run

# Build para Android
flutter build apk

# Build para iOS
flutter build ios
```

## ⚠️ Importante

- O arquivo `firebase_options.dart` atual é um **placeholder**
- Execute `flutterfire configure` para gerar as configurações reais
- Nunca commite credenciais do Firebase no Git
- Adicione `firebase_options.dart` ao `.gitignore` se compartilhar o código

## 🆘 Troubleshooting

### Erro: "DefaultFirebaseOptions not configured"

- Execute `flutterfire configure` para gerar as configurações

### Erro: "User not found"

- Certifique-se de habilitar Email/Password no Firebase Console
- Crie um usuário de teste manualmente no console

### Erro: "Permission denied"

- Verifique as regras de segurança do Firestore
- Certifique-se de que o usuário está autenticado

### Exercícios não aparecem

- Execute o script de inicialização uma vez
- Verifique no Firebase Console se os dados foram salvos

## 📚 Recursos

- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)

---

**🎉 Seu app agora está totalmente integrado com Firebase!**
