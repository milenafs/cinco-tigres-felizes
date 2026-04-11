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

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project Structure

This project follows a **layer-based architecture** to keep code organized and maintainable:

```
lib/
├── main.dart                 # App entry point - initializes the app
├── screens/                  # Full pages/screens shown to users
│   └── home_screen.dart      # Example: Home page screen
├── widgets/                  # Reusable UI components
│   └── (custom buttons, cards, forms, etc.)
├── models/                   # Data structures
│   └── vacina_model.dart    # Example: Vacina data model
└── services/                 # Business logic & data handling
    └── vacina_service.dart  # Example: vacina operations
```

### Each Folder:

- **`main.dart`** - Entry point of your app. Sets up the app theme and navigation.
- **`screens/`** - Full pages that users see. Each screen is a StatefulWidget or StatelessWidget. Example: login screen, home screen, settings screen.
- **`widgets/`** - Reusable UI components used across multiple screens. Example: custom buttons, product cards, input forms.
- **`models/`** - Data classes that represent your app's entities. Example: User, Product, Counter.
- **`services/`** - Contains business logic and data handling. Services manage state and calculations. Example: authentication logic, API calls, counter operations.

### Run project

```
flutter run -d chrome
```
