# ES-PI3-2026-T1-G24

## 📌 Projeto MesclaInvest

Projeto desenvolvido na disciplina **Projeto Integrador 3** do curso de **Engenharia de Software da PUC-Campinas (2026)**.

O **MesclaInvest** é uma plataforma acadêmica que simula um ambiente digital de investimento em startups universitárias vinculadas ao ecossistema **Mescla** da PUC-Campinas. A proposta do sistema é permitir que investidores visualizem projetos inovadores, acompanhem seu desenvolvimento e realizem investimentos simulados.

O objetivo do projeto é explorar conceitos de:

- investimento em startups
- tokenização e blockchain
- plataformas digitais de investimento
- integração entre universidade e sociedade

A aplicação busca incentivar uma cultura de **inovação, transparência e apoio a projetos empreendedores** desenvolvidos por estudantes.

---

# 🎯 Objetivo do Projeto

Desenvolver uma **plataforma digital de investimentos simulados em startups universitárias**, permitindo que usuários investidores:

- visualizem startups do ecossistema Mescla
- acompanhem informações sobre os projetos
- realizem investimentos simulados
- acompanhem o desempenho dos investimentos

O projeto possui caráter **educacional**, sendo utilizado para aprendizado de conceitos de engenharia de software e empreendedorismo tecnológico.

---

# 🧩 Funcionalidades Esperadas

Entre as funcionalidades previstas para o sistema estão:

- Cadastro e autenticação de usuários investidores
- Visualização de startups disponíveis para investimento
- Página de detalhes de cada startup
- Realização de investimentos simulados
- Acompanhamento do portfólio de investimentos
- Histórico de transações
- Painel de controle do usuário
- Sistema administrativo
- Upload e gerenciamento de arquivos
- Integração com Firebase
- Sistema de perguntas e respostas entre investidores e startups

---

# 🛠️ Tecnologias Utilizadas

## Frontend

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

## Backend

- Node.js
- TypeScript
- Firebase Functions
- Firebase Admin SDK
- API REST

## Outros

- Git / GitHub
- Firebase Hosting
- Docker (opcional)

---

# 📁 Estrutura de Pastas

## Frontend (`frontend/mescla_invest`)

```txt
frontend/
└── mescla_invest/
    ├── android/                 # Configurações Android
    ├── ios/                     # Configurações iOS
    ├── web/                     # Configurações Web
    ├── assets/                  # Arquivos estáticos
    │
    ├── lib/
    │   ├── constants/           # Constantes globais
    │   ├── formatters/          # Formatadores e helpers
    │   ├── models/              # Models da aplicação
    │   ├── screens/             # Telas da aplicação
    │   ├── services/            # Serviços e integrações
    │   ├── utils/               # Utilitários gerais
    │   ├── widgets/             # Widgets reutilizáveis
    │   │
    │   ├── firebase_options.dart
    │   └── main.dart
    │
    ├── test/                    # Testes
    │
    ├── pubspec.yaml
    └── analysis_options.yaml
```

---

## Backend

O backend segue uma arquitetura modular baseada em **features**, onde cada funcionalidade possui sua própria estrutura interna.  
Todas as features seguem o mesmo padrão utilizado na pasta `orders/`.

### Estrutura Base das Features

```txt
backend/
└── src/
    └── features/
        ├── orders/
        │   ├── controllers/     # Controladores HTTP
        │   ├── services/        # Regras de negócio
        │   ├── repositories/    # Acesso ao banco de dados
        │   ├── dto/             # Objetos de transferência de dados
        │   ├── models/          # Models e interfaces
        │   ├── routes/          # Rotas da feature
        │   ├── validations/     # Validações
        │   ├── middlewares/     # Middlewares específicos
        │   └── index.ts         # Exportações da feature
        │
        ├── auth/
        ├── users/
        ├── startups/
        ├── investments/
        └── wallets/
```

### Organização Geral do Backend

```txt
backend/
├── src/
│   ├── config/                  # Configurações globais
│   ├── database/                # Configuração do banco
│   ├── shared/                  # Recursos compartilhados
│   ├── middlewares/             # Middlewares globais
│   ├── utils/                   # Funções utilitárias
│   ├── routes/                  # Rotas principais
│   └── features/                # Features do sistema
│
├── package.json
├── tsconfig.json
└── firebase.json
```

---

# 🧠 Arquitetura do Projeto

O sistema utiliza uma arquitetura baseada em separação de responsabilidades:

- **Frontend Flutter**
  - Responsável pela interface e experiência do usuário
  - Consome APIs e serviços Firebase

- **Backend Node.js**
  - Responsável pelas regras de negócio
  - Controle de autenticação
  - Persistência e manipulação de dados

- **Firebase**
  - Autenticação
  - Banco de dados
  - Storage
  - Hosting
  - Cloud Functions

---

# 🚀 Como Executar o Projeto

## Frontend

```bash
cd frontend/mescla_invest

flutter pub get
flutter run
```

---

## Backend

```bash
cd backend

npm install
npm run dev
```

---

# 👥 Integrantes do Grupo

| RA       | Nome                               |
| -------- | ---------------------------------- |
| 25000636 | Cristian Eduardo Fava              |
| 25009767 | Gustavo Antônio Marino             |
| 25000294 | Vinicius Santuci Virgolino         |

---

# 👨‍🏫 Orientação

Disciplina: **Projeto Integrador 3**  
Curso: **Engenharia de Software – PUC-Campinas**  
Ano: **2026**

---

# ⚠️ Observação

Este projeto possui **finalidade exclusivamente acadêmica**, desenvolvido no contexto da disciplina **Projeto Integrador 3** da PUC-Campinas.
