# Instalação — New Gym App

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.9.2+
- [Git](https://git-scm.com/)
- Conta no [Firebase](https://console.firebase.google.com/) com projeto configurado
- Chave de API do [Google Gemini](https://ai.google.dev/)
- Android Studio (para emulador Android) ou Chrome (para Web)

---

## Passos

**1. Clonar e instalar dependências**
```bash
git clone https://github.com/seu-usuario/new_gym_app.git
cd new_gym_app
flutter pub get
```

**2. Configurar Firebase**
```bash
# Instalar CLI (caso não tenha)
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Vincular projeto Firebase
firebase login
flutterfire configure
```
Isso gera `lib/firebase_options.dart` automaticamente. Habilite **Authentication (Email/Password)** e **Firestore** no Firebase Console.

**3. Configurar a chave Gemini**

Crie um arquivo `.env` na raiz do projeto:
```
GEMINI_API_KEY=sua_chave_aqui
```
Certifique-se de que `.env` está no `.gitignore`.

**4. Executar**
```bash
# Android (emulador)
flutter run -d emulator-5554 --dart-define-from-file=.env

# Web (Chrome)
flutter run -d chrome --dart-define-from-file=.env
```

---

## Primeiro acesso

1. Criar conta de **Personal Trainer** (preencher o CREF)
2. Cadastrar um aluno de teste
3. Criar uma anamnese e compartilhar com o aluno
4. Responder a anamnese como aluno e aguardar a análise da IA
5. Acessar os insights e gerar sugestões de treino como personal

---

## Problemas comuns

| Erro | Solução |
|------|---------|
| `Firebase not initialized` | Verificar se `firebase_options.dart` existe em `lib/` |
| `Permission denied` no Firestore | Verificar as regras de segurança em `firestore.rules` |
| `Gemini API key invalid` | Confirmar que a chave no `.env` está correta e o arquivo foi salvo |
| App não encontra emulador | Executar `flutter devices` para listar dispositivos disponíveis |

---

**Última atualização:** Junho 2026
