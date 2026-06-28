# Guia de Instalação - New Gym App

## Índice
- [Pré-requisitos](#pré-requisitos)
- [Instalação do Flutter](#instalação-do-flutter)
- [Configuração do Projeto](#configuração-do-projeto)
- [Configuração do Firebase](#configuração-do-firebase)
- [Configuração da API Gemini](#configuração-da-api-gemini)
- [Executando o Projeto](#executando-o-projeto)
- [Build de Produção](#build-de-produção)
- [Troubleshooting](#troubleshooting)

---

## Pré-requisitos

### 1. **Sistema Operacional**
- ✅ Linux (Ubuntu 20.04+, Pop!_OS, Fedora, etc.)
- ✅ macOS 10.14+
- ✅ Windows 10+

### 2. **Ferramentas Necessárias**

#### Git
```bash
# Linux (Debian/Ubuntu)
sudo apt update
sudo apt install git

# macOS
brew install git

# Verificar instalação
git --version
```

#### Node.js e npm (para Firebase CLI)
```bash
# Linux (usando nvm - recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
nvm use --lts

# macOS
brew install node

# Verificar instalação
node --version
npm --version
```

---

## Instalação do Flutter

### 1. **Download do Flutter SDK**

#### Linux/macOS
```bash
# Criar diretório para o Flutter
mkdir -p ~/development
cd ~/development

# Clonar o repositório do Flutter
git clone https://github.com/flutter/flutter.git -b stable

# Adicionar ao PATH
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc  # ou ~/.zshrc
source ~/.bashrc  # ou source ~/.zshrc
```

#### Windows
1. Baixe o SDK: https://docs.flutter.dev/get-started/install/windows
2. Extraia para `C:\src\flutter`
3. Adicione ao PATH: `C:\src\flutter\bin`

### 2. **Verificar Instalação**
```bash
flutter doctor
```

**Saída esperada:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.38.2, on Linux, locale pt_BR.UTF-8)
[✓] Chrome - develop for the web
[!] Android toolchain (instalar se quiser build Android)
[!] Xcode (apenas macOS para build iOS)
```

### 3. **Instalar Dependências**

#### Para Web (recomendado)
```bash
# Chrome já instalado? Verifique:
google-chrome --version

# Senão, instale:
# Linux
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# macOS
brew install --cask google-chrome
```

#### Para Android (opcional)
```bash
# Instalar Android Studio
# Linux: https://developer.android.com/studio
# macOS: brew install --cask android-studio

# Aceitar licenças
flutter doctor --android-licenses
```

---

## Configuração do Projeto

### 1. **Clonar o Repositório**
```bash
cd ~/Projects  # ou seu diretório preferido
git clone https://github.com/seu-usuario/new_gym_app.git
cd new_gym_app
```

### 2. **Instalar Dependências do Flutter**
```bash
flutter pub get
```

**Saída esperada:**
```
Running "flutter pub get" in new_gym_app...
Resolving dependencies... (2.5s)
+ cloud_firestore 5.5.2
+ firebase_auth 5.3.3
+ firebase_core 3.8.1
+ flutter_riverpod 3.0.1
+ go_router 16.2.4
+ google_generative_ai 0.4.0
+ http 1.2.0
... (mais pacotes)
Got dependencies!
```

### 3. **Verificar Erros**
```bash
flutter analyze
```

**Saída esperada:**
```
Analyzing new_gym_app...
No issues found! (ran in 3.2s)
```

---

## Configuração do Firebase

### 1. **Criar Projeto no Firebase**

1. Acesse: https://console.firebase.google.com/
2. Clique em **"Adicionar projeto"**
3. Nome: `new-gym-app` (ou seu preferido)
4. Desabilite Google Analytics (pode habilitar depois)
5. Clique em **"Criar projeto"**

### 2. **Instalar Firebase CLI**
```bash
npm install -g firebase-tools

# Verificar instalação
firebase --version
```

### 3. **Login no Firebase**
```bash
firebase login
```
- Abrirá navegador para autenticação
- Autorize o acesso
- Volte ao terminal

### 4. **Instalar FlutterFire CLI**
```bash
dart pub global activate flutterfire_cli

# Adicionar ao PATH (se necessário)
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

### 5. **Configurar Firebase no Projeto**
```bash
cd ~/Projects/new_gym_app

# Configurar FlutterFire
flutterfire configure
```

**Passos interativos:**
```
? Select a Firebase project to configure your Flutter application with:
  > new-gym-app (new-gym-app-123456)

? Which platforms should your configuration support?
  [✓] android
  [✓] ios
  [✓] web

✓ Firebase configuration file lib/firebase_options.dart generated successfully
```

### 6. **Habilitar Serviços no Firebase Console**

#### Authentication
1. Console → Build → Authentication
2. Clique em **"Get started"**
3. Aba **"Sign-in method"**
4. Habilite **"Email/Password"**
5. Salve

#### Firestore Database
1. Console → Build → Firestore Database
2. Clique em **"Create database"**
3. Selecione **"Start in test mode"** (temporário)
4. Escolha região: `southamerica-east1` (São Paulo)
5. Clique em **"Enable"**

⚠️ **IMPORTANTE:** Após criar, atualize as regras de segurança (ver [FIRESTORE_SECURITY_RULES.md](../FIRESTORE_SECURITY_RULES.md))

### 7. **Atualizar Regras de Segurança**
```bash
# Copiar regras para arquivo local
firebase init firestore

# Editar firestore.rules com as regras do projeto
# (Ver documentação em FIRESTORE_SECURITY_RULES.md)

# Fazer deploy das regras
firebase deploy --only firestore:rules
```

---

## Configuração da API Gemini

### 1. **Obter API Key**

1. Acesse: https://ai.google.dev/
2. Clique em **"Get API Key"**
3. Aceite os termos
4. Clique em **"Create API key in new project"**
5. Copie a chave (ex: `AIzaSyA...`)

### 2. **Configurar no Projeto**

**Opção 1: Direto no código (desenvolvimento)**
```bash
# Editar o arquivo de providers
nano lib/features/anamnesis/presentation/providers/anamnesis_providers.dart
```

Localize a linha 15:
```dart
const apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

Substitua por:
```dart
const apiKey = 'AIzaSyA...';  // Sua chave real
```

**Opção 2: Variável de ambiente (recomendado para produção)**

1. Crie arquivo `.env` na raiz do projeto:
```bash
echo "GEMINI_API_KEY=AIzaSyA..." > .env
```

2. Adicione ao `.gitignore`:
```bash
echo ".env" >> .gitignore
```

3. Instale pacote para ler .env:
```bash
flutter pub add flutter_dotenv
```

4. Carregue no `main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

5. Use no provider:
```dart
final apiKey = dotenv.env['GEMINI_API_KEY']!;
```

### 3. **Verificar Funcionamento**

Execute teste de API:
```bash
# Criar arquivo de teste
cat > test_gemini.dart << 'EOF'
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final model = GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: 'SUA_CHAVE_AQUI',
  );

  final response = await model.generateContent([
    Content.text('Diga "API funcionando!"')
  ]);

  print(response.text);
}
EOF

# Executar
dart test_gemini.dart
```

**Saída esperada:**
```
API funcionando!
```

---

## Executando o Projeto

### 1. **Web (Recomendado)**
```bash
flutter run -d chrome
```

**Saída:**
```
Launching lib/main.dart on Chrome in debug mode...
Building application for the web...
✓ Built build/web
Running application on Chrome...
```

Abrirá automaticamente em `http://localhost:XXXX`

### 2. **Android (Emulador)**
```bash
# Listar dispositivos
flutter devices

# Executar
flutter run -d <device-id>
```

### 3. **iOS (macOS apenas)**
```bash
flutter run -d iPhone
```

### 4. **Hot Reload**
Após executar, você pode:
- `r` → Hot reload (mantém estado)
- `R` → Hot restart (reseta estado)
- `q` → Sair

---

## Build de Produção

### 1. **Web**
```bash
# Build otimizado
flutter build web --release

# Arquivos gerados em: build/web/
```

**Deploy no Firebase Hosting:**
```bash
firebase init hosting
# Escolha build/web como public directory
# Configure como single-page app: Yes

firebase deploy --only hosting
```

### 2. **Android APK**
```bash
# Build APK
flutter build apk --release

# APK gerado em: build/app/outputs/flutter-apk/app-release.apk
```

**Assinar APK (para Play Store):**
```bash
# Criar keystore
keytool -genkey -v -keystore ~/new-gym-app-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias new-gym-app

# Configurar em android/key.properties
# Seguir: https://docs.flutter.dev/deployment/android#signing-the-app
```

### 3. **Android AAB (Play Store)**
```bash
flutter build appbundle --release

# AAB gerado em: build/app/outputs/bundle/release/app-release.aab
```

### 4. **iOS (macOS apenas)**
```bash
flutter build ios --release

# Seguir: https://docs.flutter.dev/deployment/ios
```

---

## Troubleshooting

### ❌ Erro: "Firebase not initialized"

**Solução:**
```dart
// Certifique-se que main.dart tem:
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

### ❌ Erro: "Gemini API key invalid"

**Solução:**
1. Verifique se copiou a chave completa
2. Teste no navegador: https://generativelanguage.googleapis.com/v1beta/models?key=SUA_CHAVE
3. Se retornar JSON com modelos, a chave está válida

### ❌ Erro: "Permission denied" no Firestore

**Solução:**
1. Verifique regras em Firebase Console → Firestore → Rules
2. Para desenvolvimento, use regras permissivas:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
3. **Não use em produção!** Implemente regras corretas depois.

### ❌ Erro: "Pod install failed" (iOS)

**Solução:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### ❌ Erro: "Gradle build failed" (Android)

**Solução:**
```bash
# Limpar build
flutter clean
cd android
./gradlew clean
cd ..

# Rebuild
flutter pub get
flutter build apk
```

### ❌ Erro: "Chrome not found"

**Solução:**
```bash
# Linux
sudo apt install google-chrome-stable

# Configurar caminho
flutter config --chrome-path /usr/bin/google-chrome
```

---

## Variáveis de Ambiente

Crie `.env` na raiz do projeto (opcional):

```env
# Gemini API
GEMINI_API_KEY=AIzaSyA...

# Firebase (já configurado via FlutterFire)
# Não é necessário duplicar aqui
```

**Adicione ao .gitignore:**
```
.env
*.env
```

---

## Scripts Úteis

Crie arquivo `Makefile` (opcional):

```makefile
.PHONY: get clean run-web run-android build-web build-apk deploy

get:
	flutter pub get

clean:
	flutter clean

run-web:
	flutter run -d chrome

run-android:
	flutter run -d android

build-web:
	flutter build web --release

build-apk:
	flutter build apk --release

deploy:
	firebase deploy --only hosting

analyze:
	flutter analyze

test:
	flutter test
```

**Uso:**
```bash
make get      # Instalar dependências
make run-web  # Executar no Chrome
make deploy   # Deploy no Firebase Hosting
```

---

## Checklist de Instalação

- [ ] Flutter SDK instalado e verificado (`flutter doctor`)
- [ ] Git configurado
- [ ] Projeto clonado
- [ ] Dependências instaladas (`flutter pub get`)
- [ ] Firebase CLI instalado
- [ ] Firebase configurado (`flutterfire configure`)
- [ ] Authentication habilitado
- [ ] Firestore habilitado
- [ ] Regras de segurança atualizadas
- [ ] Gemini API Key configurada
- [ ] Projeto executa sem erros (`flutter run`)
- [ ] `.env` adicionado ao `.gitignore`

---

## Próximos Passos

Após instalação concluída:

1. **Testar sistema de autenticação:**
   - Criar conta de personal trainer
   - Criar conta de aluno

2. **Criar dados de exemplo:**
   - Adicionar exercícios
   - Criar treinos de exemplo

3. **Testar anamnese IA:**
   - Criar anamnese para aluno
   - Responder perguntas
   - Ver insights gerados

4. **Configurar ambiente de produção:**
   - Regras de segurança finais
   - Variáveis de ambiente
   - CI/CD (GitHub Actions)

---

**Última atualização:** Junho 2026

**Precisa de ajuda?** Abra uma issue no GitHub!
