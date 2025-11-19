# 🚨 AÇÃO NECESSÁRIA: Atualizar Regras do Firestore

## ❌ Erro Atual

```
Missing or insufficient permissions
```

## ✅ Solução

### Passo 1: Abrir Firebase Console

Execute no terminal:

```powershell
start https://console.firebase.google.com/project/newgymapp-f3667/firestore/rules
```

### Passo 2: Substituir as Regras

**Deletar** todas as regras atuais e **colar** estas:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // USUÁRIOS: Qualquer usuário autenticado pode ler
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }

    // EXERCÍCIOS: Qualquer usuário autenticado pode ler e escrever
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // ATRIBUIÇÕES: Qualquer usuário autenticado
    match /user_exercises/{assignmentId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Passo 3: Publicar

1. Clique no botão **"Publicar"** (canto superior direito)
2. Aguarde 5-10 segundos para propagar

### Passo 4: Testar

1. Reinicie o app (Hot Restart no terminal: pressione `R`)
2. Faça login como Personal Trainer
3. Clique em "Gerenciar Treinos"
4. Deve mostrar a lista de alunos agora! ✅

## 📝 Notas

- Estas são regras **permissivas** para desenvolvimento
- Em produção, use as regras mais restritas do arquivo `FIRESTORE_SECURITY_RULES.md`
- O erro acontecia porque a query `where('role', isEqualTo: 'student')` requer:
  1. Índice no Firestore (resolvido: filtramos no código agora)
  2. Permissões de leitura (resolvido: atualizando regras)

## 🔍 Verificar se Funcionou

Após atualizar as regras, você deve ver no console do app:

- Lista de alunos carregada
- Sem mensagens de erro de permissão
