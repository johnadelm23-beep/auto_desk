# AutoDesk 

**AutoDesk** is a modern car management and workshop management application built with Flutter. It helps users organize vehicle information, manage car records, track maintenance activities, and keep important vehicle data accessible in one place.

## Features

- **Car Management:** Add, edit, view, and manage vehicle records.
- **Vehicle Information:** Store car details, including brand, model, chassis number, and other relevant information.
- **Car Images:** Attach and manage vehicle photos.
- **Dashboard:** View important statistics and car-related information.
- **Local Database:** Store data locally for reliable offline access.
- **Notifications:** Receive scheduled reminders and important updates.
- **Localization:** Support for Arabic (RTL) and English (LTR).
- **Modern UI:** Responsive interface with a consistent design system.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Architecture:** Clean Architecture (Feature-First)
- **State Management:** Flutter Bloc / Cubit
- **Dependency Injection:** GetIt
- **Navigation:** GoRouter
- **Local Database:** Drift / SQLite
- **Responsive UI:** Flutter ScreenUtil
- **Localization:** Easy Localization
- **Notifications:** Flutter Local Notifications

## Project Structure

```text
lib/
├── core/
│   ├── database/
│   ├── di/
│   ├── localization/
│   ├── routing/
│   └── ...
│
├── features/
│   ├── cars/
│   ├── dashboard/
│   └── ...
│
└── main.dart

assets/
├── images/
├── animations/
└── translations/
    ├── en.json
    └── ar.json
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code

### Installation

1. Clone the repository:

```bash
git clone YOUR_REPOSITORY_URL
```

2. Navigate to the project directory:

```bash
cd auto_desk
```

3. Install dependencies:

```bash
flutter pub get
```

4. Generate Drift database code if needed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

5. Run the application:

```bash
flutter run
```

## Build Release APK

```bash
flutter build apk --release
```

For optimized architecture-specific APKs:

```bash
flutter build apk --release --split-per-abi
```

## Localization

AutoDesk supports:

- English (LTR)
- Arabic (RTL)

## Database

AutoDesk uses Drift with SQLite for local data persistence, allowing vehicle records to remain available without an internet connection.

## License

This project is currently developed as a private project. All rights reserved unless otherwise specified.