# 📋 Checklist - O que falta para o New Gym App

**Última atualização:** 18/06/2026

---

## 🔴 CRÍTICO - Bloqueadores para Produção

### 1. ⚙️ Configuração da API Gemini

**Status:** 🔴 Pendente  
**Prioridade:** CRÍTICA  
**Impacto:** Todo o sistema de IA não funciona sem isso

**Arquivo:** `lib/features/anamnesis/presentation/providers/anamnesis_providers.dart` (linha 25)

**Ação necessária:**
```bash
# Opção 1: Variável de ambiente (RECOMENDADO)
echo "GEMINI_API_KEY=sua-chave-aqui" > .env
# Adicionar ao .gitignore
echo ".env" >> .gitignore
```

**Como obter a chave:**
1. Acesse: https://ai.google.dev/
2. Clique em "Get API Key"
3. Crie projeto ou use existente
4. Copie a chave (ex: `AIzaSyA...`)

**Custo:** Grátis até 60 requests/min

---

### 2. 🔒 Deploy das Regras de Segurança do Firestore

**Status:** 🔴 Pendente  
**Prioridade:** CRÍTICA  
**Impacto:** Dados expostos sem proteção adequada

**Arquivo:** Não existe `firestore.rules` no projeto

**Ação necessária:**
```bash
# 1. Criar arquivo de regras
touch firestore.rules

# 2. Copiar regras de FIRESTORE_SECURITY_RULES.md

# 3. Fazer deploy
firebase deploy --only firestore:rules
```

**Documentação:** [FIRESTORE_SECURITY_RULES.md](FIRESTORE_SECURITY_RULES.md)

---

### 3. 📝 Arquivo LICENSE

**Status:** 🔴 Ausente  
**Prioridade:** ALTA  
**Impacto:** Projeto sem licença clara

**Ação necessária:**
```bash
# Criar arquivo LICENSE com MIT License
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2026 Junior Trindade

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

---

## 🟡 IMPORTANTE - Antes do Deploy

### 4. 🔐 Atualizar .gitignore

**Status:** 🟡 Incompleto  
**Prioridade:** ALTA  
**Impacto:** Pode vazar secrets para Git

**Adicionar ao .gitignore:**
```bash
# Adicionar ao final do .gitignore
cat >> .gitignore << 'EOF'

# API Keys e Secrets
.env
.env.local
.env.*.local
*.key
secrets/

# Firebase
firestore.rules
firestore.indexes.json
.firebase/
EOF
```

---

### 5. ✅ Testes Unitários

**Status:** 🟡 Não implementado  
**Prioridade:** MÉDIA  
**Impacto:** Sem cobertura de testes

**Criar estrutura de testes:**
```bash
# Criar pasta de testes
mkdir -p test/services
mkdir -p test/providers
mkdir -p test/models

# Exemplo de teste
cat > test/services/gemini_service_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:new_gym_app/core/services/gemini_service.dart';

void main() {
  group('GeminiService', () {
    test('should initialize with valid API key', () {
      final service = GeminiService(apiKey: 'test-key');
      expect(service, isNotNull);
    });
    
    test('should throw error with empty API key', () {
      expect(
        () => GeminiService(apiKey: ''),
        throwsException,
      );
    });
  });
}
EOF
```

**Executar testes:**
```bash
flutter test
```

---

### 6. 📸 Screenshots e Demos

**Status:** 🟡 Ausente  
**Prioridade:** MÉDIA  
**Impacto:** Documentação incompleta

**Criar pasta de assets para docs:**
```bash
mkdir -p docs/assets/screenshots
mkdir -p docs/assets/gifs
```

**Screenshots necessários:**
- [ ] Tela de login
- [ ] Dashboard do personal
- [ ] Lista de alunos
- [ ] Criação de treino
- [ ] Lista de anamneses
- [ ] Resposta de anamnese (aluno)
- [ ] Insights da IA
- [ ] Sugestões de treino

**GIF/Vídeo demonstrativo:**
- [ ] Fluxo completo de anamnese (30s-60s)

**Atualizar README.md:**
```markdown
## 🎬 Demo e Screenshots

### Dashboard Personal
![Dashboard](docs/assets/screenshots/dashboard.png)

### Anamnese IA
![Anamnese Flow](docs/assets/gifs/anamnesis-flow.gif)
```

---

### 7. 🔗 Links de Contato no README

**Status:** 🟡 Placeholder  
**Prioridade:** BAIXA  
**Impacto:** Links quebrados na documentação

**Atualizar em README.md:**
```markdown
- 📧 Email: [junior@example.com](mailto:junior@example.com)
- 💼 LinkedIn: [linkedin.com/in/juniortrindade](https://linkedin.com/in/juniortrindade)
- 🐛 GitHub: [@juniortrindade](https://github.com/juniortrindade)
```

---

## 🟢 OPCIONAL - Melhorias Futuras

### 8. 📊 CI/CD com GitHub Actions

**Status:** 🟢 Planejado  
**Prioridade:** BAIXA  

**Criar `.github/workflows/ci.yml`:**
```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.2'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

---

### 9. 📄 Templates de Issue e PR

**Status:** 🟢 Planejado  
**Prioridade:** BAIXA  

**Criar `.github/ISSUE_TEMPLATE/bug_report.md`:**
```markdown
---
name: Bug Report
about: Relatar um bug
---

## Descrição do Bug
[Descrição clara do problema]

## Passos para Reproduzir
1. 
2. 
3. 

## Comportamento Esperado
[O que deveria acontecer]

## Screenshots
[Se aplicável]

## Ambiente
- Dispositivo: 
- OS: 
- Versão do app: 
```

---

### 10. 🌐 Deploy Web (Firebase Hosting)

**Status:** 🟢 Planejado  
**Prioridade:** BAIXA  

**Configurar hosting:**
```bash
# Inicializar hosting
firebase init hosting

# Build
flutter build web --release

# Deploy
firebase deploy --only hosting
```

---

## 📊 Resumo do Status

| Categoria | Status | Itens Pendentes |
|-----------|--------|-----------------|
| **🔴 Crítico** | 60% | 3/5 |
| **🟡 Importante** | 20% | 4/5 |
| **🟢 Opcional** | 0% | 3/3 |
| **TOTAL** | **46%** | **10/13** |

---

## 🎯 Plano de Ação Recomendado

### Semana 1 (Crítico)
- [x] ~~Documentação modularizada~~ ✅
- [ ] Configurar Gemini API Key
- [ ] Criar e deploy firestore.rules
- [ ] Criar arquivo LICENSE
- [ ] Atualizar .gitignore

### Semana 2 (Importante)
- [ ] Implementar testes unitários básicos
- [ ] Capturar screenshots
- [ ] Atualizar links de contato
- [ ] Testar sistema end-to-end

### Semana 3+ (Opcional)
- [ ] Configurar CI/CD
- [ ] Deploy web em produção
- [ ] Templates de issue/PR
- [ ] Começar Fase 3 do roadmap

---

## 🚀 Comandos Rápidos

### Para começar AGORA:

```bash
# 1. Configurar API Key (FAZER PRIMEIRO!)
echo "GEMINI_API_KEY=sua-chave-aqui" > .env
echo ".env" >> .gitignore

# 2. Criar LICENSE
curl -o LICENSE https://raw.githubusercontent.com/licenses/license-templates/master/templates/mit.txt

# 3. Atualizar gitignore
echo -e "\n# Secrets\n.env\n*.key" >> .gitignore

# 4. Testar
flutter run -d chrome

# 5. Verificar erros
flutter analyze
```

---

## 📞 Precisa de Ajuda?

- 📚 [Documentação](docs/)
- 🐛 [Abrir Issue](https://github.com/seu-usuario/new_gym_app/issues)
- 💬 [Discussões](https://github.com/seu-usuario/new_gym_app/discussions)

---

**Próxima revisão:** 25/06/2026  
**Responsável:** Junior Trindade
