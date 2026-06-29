# Stack Tecnológica — New Gym App

## Dependências principais

| Categoria | Tecnologia | Versão | Papel |
|-----------|-----------|--------|-------|
| Framework | Flutter | 3.9.2 | Interface multiplataforma (Android, iOS, Web) |
| Linguagem | Dart | 3 | Tipagem forte, compilação nativa |
| Estado | Riverpod | ^3.0.1 | Gerenciamento de estado reativo |
| Navegação | GoRouter | ^16.2.4 | Roteamento declarativo com deep linking |
| Auth | Firebase Auth | ^5.3.3 | Autenticação com sessão persistente |
| Banco de dados | Cloud Firestore | ^5.5.2 | NoSQL em tempo real com suporte offline |
| IA | Google Generative AI | ^0.4.7 | Integração com Gemini (`gemini-3.5-flash`) |
| Localização | flutter_localizations | SDK | Suporte a pt_BR (date picker, etc.) |

---

## Decisões de tecnologia

### Por que Flutter?

Um único código-base entrega Android, iOS e Web. Para o escopo do TCC, o foco é Android (emulador) e Web (Chrome), sem abrir mão da portabilidade futura.

### Por que Riverpod?

Menos boilerplate que BLoC, compile-time safety, e suporte nativo a `StreamProvider` para dados em tempo real do Firestore — ideal para o fluxo reativo da anamnese.

### Por que Firestore e não SQL?

O fluxo da anamnese exige sincronização em tempo real entre aluno (respondendo) e personal (acompanhando o status). O Firestore entrega isso nativamente, com suporte offline e sem necessidade de servidor dedicado — essencial dentro das restrições de um TCC.

### Por que Gemini e não GPT-4?

Custo estimado por anamnese completa: **~R$ 0,08** com `gemini-3.5-flash`. O GPT-4o equivalente custaria cerca de 10× mais. O modelo Gemini também oferece janela de contexto suficiente para processar toda a anamnese em uma única chamada.

---

**Última atualização:** Junho 2026
