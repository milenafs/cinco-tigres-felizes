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

## Arquitetura do projeto

O projeto segue a **Arquitetura Baseada em Camadas**, também conhecida como N-tier, essa arquitetura estrutura o projeto em camadas independentes. Um exemplo famoso dessa arquitetura é o modelo MVC (Model, View, Controller), o View é responsável pela UI, o Model é responsável pelos dados e o Controller pela manipulação dos dados.

A estrutura desse projeto se assemelha ao modelo MVC com pequenas adaptações às especificidades de um projeto mobile. A camada de Data mantém o dados usados pela aplicação, a camada Models tem os modelos de dados da aplicação, Screens tem as telas do aplicativo, Services acessa os dados guardados e a camada de Widgets contém componentes visuais compartilhados por várias telas.

O principal benefício dessa arquitetura é a facilidade de entendimento e manutenção do projeto, além de isolar responsabilidades deixando o código mais limpo e organizado.

```
lib/
├── data/             
├── screens/                
├── widgets/      
├── models/     
└── services/             
```
<img width="548" height="588" alt="image" src="https://github.com/user-attachments/assets/d102a041-143a-454f-b356-90b2b3bbd68a" />


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
