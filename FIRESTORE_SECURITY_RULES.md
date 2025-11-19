# Regras de Segurança do Firestore - Sistema com Alunos e Personal Trainers

## 📋 Estrutura das Collections

```
firestore/
├── users/
│   └── {userId}/
│       ├── name: string
│       ├── email: string
│       ├── photoUrl: string
│       ├── role: string ("student" | "personalTrainer")
│       └── personalTrainerId: string (apenas para alunos, ID do personal responsável)
│
├── exercises/
│   └── {exerciseId}/
│       ├── name: string
│       ├── workoutType: string
│       ├── series: number
│       ├── reps: number
│       ├── imageUrl: string
│       └── instructions: string
│
├── user_exercises/
│   └── {assignmentId}/
│       ├── userId: string (ID do aluno)
│       ├── exerciseId: string
│       ├── assignedBy: string (ID do personal)
│       ├── assignedAt: timestamp
│       ├── customSeries: number (opcional)
│       ├── customReps: number (opcional)
│       └── notes: string (opcional)
│
└── workouts/
    └── {workoutId}/
        ├── id: string
        ├── name: string
        ├── studentId: string (ID do aluno)
        ├── createdBy: string (ID do personal)
        ├── exercises: array[
        │   {
        │     exerciseId: string,
        │     series: number,
        │     reps: number,
        │     notes: string (opcional)
        │   }
        │ ]
        ├── createdAt: timestamp
        └── updatedAt: timestamp (opcional)
```

## 🔒 Regras de Segurança

### ⚠️ IMPORTANTE: Use estas regras durante desenvolvimento

Cole estas regras no **Firebase Console** → **Firestore Database** → **Regras**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ===== MODO DESENVOLVIMENTO (TEMPORÁRIO) =====
    // TODO: Substituir por regras mais restritas em produção

    // USUÁRIOS: Qualquer usuário autenticado pode ler
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }

    // EXERCÍCIOS: Qualquer usuário autenticado pode ler
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // ATRIBUIÇÕES: Qualquer usuário autenticado
    match /user_exercises/{assignmentId} {
      allow read, write: if request.auth != null;
    }

    // TREINOS: Qualquer usuário autenticado pode ler e escrever
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 🔒 Regras de Produção (Usar depois de testar)

<details>
<summary>Clique para ver regras completas de produção</summary>

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Função helper para verificar se o usuário está autenticado
    function isSignedIn() {
      return request.auth != null;
    }

    // Função helper para verificar se o usuário é o dono do documento
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // Função helper para obter o role do usuário atual
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }

    // Função helper para verificar se o usuário é Personal Trainer
    function isPersonalTrainer() {
      return isSignedIn() && getUserRole() == 'personalTrainer';
    }

    // Função helper para verificar se o usuário é Aluno
    function isStudent() {
      return isSignedIn() && getUserRole() == 'student';
    }

    // ===== REGRAS PARA USUÁRIOS =====
    match /users/{userId} {
      // Leitura: Usuário pode ler seu próprio documento
      // Personal Trainers podem ler dados de todos os alunos
      allow read: if isOwner(userId) ||
                     (isPersonalTrainer() &&
                      get(/databases/$(database)/documents/users/$(userId)).data.role == 'student');

      // Escrita: Apenas o próprio usuário pode atualizar seus dados
      allow write: if isOwner(userId);

      // Criação: Permitida durante o registro (sem autenticação prévia)
      allow create: if request.auth != null;
    }

    // ===== REGRAS PARA EXERCÍCIOS =====
    match /exercises/{exerciseId} {
      // Leitura: Todos os usuários autenticados podem ler
      allow read: if isSignedIn();

      // Criar/Atualizar/Deletar: Apenas Personal Trainers
      allow create, update, delete: if isPersonalTrainer();
    }

    // ===== REGRAS PARA ATRIBUIÇÕES DE EXERCÍCIOS =====
    match /user_exercises/{assignmentId} {
      // Leitura:
      // - Aluno pode ler suas próprias atribuições
      // - Personal Trainer pode ler todas as atribuições que criou
      allow read: if isSignedIn() && (
        resource.data.userId == request.auth.uid ||
        resource.data.assignedBy == request.auth.uid
      );

      // Criar: Apenas Personal Trainers podem atribuir exercícios
      allow create: if isPersonalTrainer() &&
                       request.resource.data.assignedBy == request.auth.uid;

      // Atualizar: Apenas o Personal que atribuiu pode modificar
      allow update: if isPersonalTrainer() &&
                       resource.data.assignedBy == request.auth.uid;

      // Deletar: Apenas o Personal que atribuiu pode remover
      allow delete: if isPersonalTrainer() &&
                       resource.data.assignedBy == request.auth.uid;
    }

    // ===== REGRAS PARA TREINOS =====
    match /workouts/{workoutId} {
      // Leitura:
      // - Aluno pode ler seus próprios treinos
      // - Personal Trainer pode ler treinos que criou
      allow read: if isSignedIn() && (
        resource.data.studentId == request.auth.uid ||
        resource.data.createdBy == request.auth.uid
      );

      // Criar: Apenas Personal Trainers
      allow create: if isPersonalTrainer() &&
                       request.resource.data.createdBy == request.auth.uid;

      // Atualizar: Apenas o Personal que criou
      allow update: if isPersonalTrainer() &&
                       resource.data.createdBy == request.auth.uid;

      // Deletar: Apenas o Personal que criou
      allow delete: if isPersonalTrainer() &&
                       resource.data.createdBy == request.auth.uid;
    }
  }
}
```

</details>

## 🔐 Explicação das Regras

### Usuários (users)

- **Leitura**:
  - Usuário pode ler seus próprios dados
  - Personal Trainers podem ler dados de todos os alunos
- **Escrita**: Apenas o próprio usuário pode modificar seus dados
- **Criação**: Permitida durante registro

### Exercícios (exercises)

- **Leitura**: Qualquer usuário autenticado
- **Criar/Editar/Deletar**: Apenas Personal Trainers

### Atribuições (user_exercises)

- **Leitura**:
  - Alunos veem apenas suas atribuições
  - Personal Trainers veem atribuições que criaram
- **Criar**: Apenas Personal Trainers
- **Editar/Deletar**: Apenas o Personal que criou a atribuição

## 🧪 Teste as Regras

No Firebase Console, use o **Simulador de Regras** para testar:

### Teste 1: Aluno lê seus próprios exercícios

```javascript
// Localização: /user_exercises/{docId}
// Operação: get
// auth: { uid: "student_uid_123" }
// Deve retornar: ALLOW
```

### Teste 2: Personal atribui exercício

```javascript
// Localização: /user_exercises/{docId}
// Operação: create
// auth: { uid: "personal_uid_456" }
// Dados: { userId: "student_uid_123", assignedBy: "personal_uid_456", ... }
// Deve retornar: ALLOW
```

### Teste 3: Aluno tenta criar exercício

```javascript
// Localização: /exercises/{docId}
// Operação: create
// auth: { uid: "student_uid_123" }
// Deve retornar: DENY
```

## ⚠️ Importante

1. **Publique as regras** clicando em "Publicar" no Firebase Console
2. **Aguarde alguns segundos** para as regras propagarem
3. **Teste no app** fazendo login como aluno e como personal
4. **Monitore** logs de segurança no Console para detectar acessos negados

## 🔄 Atualizar Regras

Sempre que adicionar novas funcionalidades, atualize as regras de acordo.

### Exemplo: Adicionar histórico de treinos

```javascript
match /workout_history/{historyId} {
  allow read, write: if isOwner(resource.data.userId);
}
```
