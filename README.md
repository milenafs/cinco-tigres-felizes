# Cinco Tigres Felizes!

> Antonio Carlos Carvalho Macedo - 199152 \
> Diogo Barros de Paula - 242545 \
> Gabriela Andrade Taniguchi - 281773 \
> Larissa Soares de Oliveira - 250815 \
> Milena Furuta Shishito - 260240 

ODS: 3 - Saúde e Bem-Estar

O presente projeto busca implementar features que auxiliem a promover a conscientização dos usuários à respeito 
de medidas importantes relacionadas à sua saúde, como atualização da carteira de vacinação, lembretes de medicamentos
e de consultas, bem como uma pesquisa eficiente sobre a disponibilidade de remédios no SUS

# Arquitetura do Projeto

A arquitetura da plataforma foi desenhada para viabilizar a entrega inicial do produto de forma ágil, preservando manutenibilidade e potencial de evolução futura. Três estilos arquiteturais foram considerados, cada um respondendo a uma dimensão diferente do sistema.

---

## 1. Monólito Modular — Dimensão de Implantação

**Status: implementado**

Toda a aplicação é executada em um único processo Flutter. O código é internamente particionado em módulos independentes, alinhados aos épicos do produto:

```
lib/
├── features/
│   ├── access/        ← Épico 1: Gestão de Acesso
│   ├── habits/        ← Épico 2: Rastreamento de Hábitos e Gamificação
│   └── vaccines/      ← Épico 3: Gestão de Vacinas
```

Cada módulo é autossuficiente — possui suas próprias camadas de dados, domínio, serviço e apresentação — e não importa diretamente de outros módulos. A comunicação entre módulos ocorre apenas via camadas de integração explícitas (como o Provider registrado na `main.dart`).

Essa escolha garante velocidade de entrega agora e viabilidade de extração futura: caso o módulo de hábitos demande alta escalabilidade, ele pode ser isolado em um microsserviço sem exigir refatoração do restante da aplicação.

---

## 2. Arquitetura em Camadas — Dimensão de Estrutura Lógica

**Status: parcialmente implementado (módulo `vaccines`)**

Para a organização interna de cada módulo, o estilo adotado é a Arquitetura em Camadas, com separação estrita de responsabilidades e fluxo de dependência unidirecional:

```
presentation → services → domain ← data
```

Cada camada tem uma responsabilidade única e não conhece os detalhes das camadas acima dela:

| Camada | Responsabilidade | Exemplos no módulo `vaccines` |
|---|---|---|
| **Apresentação** | Renderizar a UI e capturar interações do usuário | `VacinacaoScreen`, `VacinaCard`, `FiltroModal` |
| **Serviço** | Centralizar lógica de aplicação e gerência de estado | `VacinasService` |
| **Domínio** | Entidades puras e contratos — sem dependência do Flutter | `Vacina`, `CalendarioVacinas`, `IVacinasRepository` |
| **Dados** | Comunicação com infraestrutura (arquivos, armazenamento local) | `VacinasRepository`, `VacinaModel` |

A implementação completa deste estilo nos módulos `access` e `habits` está prevista como evolução futura do projeto.

---

## 3. Publish/Subscribe — Dimensão de Comunicação

**Status: planejado — não implementado**

O estilo PUB/SUB foi desenhado para integrar os módulos de forma reativa e desacoplada. A plataforma possui requisitos de gamificação que exigem que eventos de um módulo disparem reações em outro sem acoplamento direto entre eles.

O fluxo planejado funciona da seguinte forma: quando o usuário conclui um registro de hábito, o módulo de Hábitos emite um evento. O módulo de Gamificação escuta esse evento de forma passiva e decide, por conta própria, se deve incrementar uma streak ou conceder um selo — sem que as regras de negócio de um módulo interfiram no escopo do outro.

Esse estilo não será implementado no escopo atual do projeto, mas a separação modular adotada no Monólito Modular foi desenhada para acomodá-lo: cada módulo já possui fronteiras bem definidas que funcionariam naturalmente como publishers e subscribers.

## Desenho detalhado da arquitetura
[Diagrama C4 Model](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=Diagrama%20C4%20Model%20-%20Plataforma%20de%20sa%C3%BAde%20e%20bem-estar&dark=auto#Uhttps%3A%2F%2Fdrive.google.com%2Fuc%3Fid%3D1Q4tgUZU3jcvvosxUZNgHhz9achLs6Vj6%26export%3Ddownload)
---

# Especificação de Requisitos e Histórias de Usuário

Abaixo estão definidos os Épicos e as Histórias de Usuário para o desenvolvimento do Cinco Tigres Felizes, escritos no formato Connextra e priorizados por valor de negócio. Todo o detalhamento, critérios de aceitação e acompanhamento de status estão registrados no **Quadro de Projetos (GitHub Projects)** e na aba de **Issues** deste repositório.

## Resumo do Backlog Priorizado

| Ordem | ID | História | Épico | Prioridade |
| :--- | :--- | :--- | :--- | :--- |
| 1 | HU 1.1 | Cadastro de conta | Gestão de Acesso | Alta |
| 2 | HU 1.2 | Login com email e senha | Gestão de Acesso | Alta |
| 3 | HU 2.1 | Registro e acompanhamento de hábitos | Hábitos/Gamificação | Alta |
| 4 | HU 2.2 | Controle de ingestão de água | Hábitos/Gamificação | Alta |
| 5 | HU 3.1 | Visualização de vacinas por faixa etária | Gestão de Vacinas | Média-Alta |
| 6 | HU 3.2 | Marcação de doses concluídas | Gestão de Vacinas | Média-Alta |
| 7 | HU 2.3 | Sistema de selos e conquistas | Hábitos/Gamificação | Média |
| 8 | HU 1.4 | Gerenciamento de perfil | Gestão de Acesso | Média |
| 9 | HU 2.4 | Streaks de hábitos | Hábitos/Gamificação | Média |
| 10 | HU 1.3 | Recuperação de senha | Gestão de Acesso | Baixa |
| 11 | HU 3.3 | Filtro e busca no catálogo de vacinas | Gestão de Vacinas | Baixa |

> **Nota sobre priorização:** O backlog está ordenado de forma decrescente por valor. O acesso à plataforma (Épico 1) é bloqueante, o rastreamento de hábitos (Épico 2) é o núcleo de valor e a gestão de vacinas (Épico 3) é o diferencial competitivo.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Run project

```
flutter run -d chrome
```
