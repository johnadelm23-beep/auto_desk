# AutoDesk – Car & Workshop Management App

**AutoDesk** is a modern Flutter application designed to simplify vehicle and workshop management. It provides an organized way to manage vehicle records, store important car information, track maintenance activities, and keep everything accessible through a clean and user-friendly interface.

Built with Flutter and Dart, AutoDesk follows a structured, maintainable architecture with an offline-first approach, allowing users to access their vehicle data without requiring an internet connection.

---

## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/669d9534-173c-486b-96ec-edce4a01859f" width="220" alt="Photo Selection Screen"/>
  <img src="https://github.com/user-attachments/assets/eff2008c-30a8-4034-850d-eb7e0d84efb8" width="220" alt="Vehicle Diagnostics Screen"/>
  <img src="https://github.com/user-attachments/assets/ad56cced-6e30-499c-bd6f-e21a70243199" width="220" alt="Cars Management Screen"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/622acb3e-0d03-4339-9a78-12c75b3a36e5" width="220" alt="Add Vehicle Step One"/>
  <img src="https://github.com/user-attachments/assets/704e6988-8a08-4fb2-9204-ba7b75e3f100" width="220" alt="Add Vehicle Screen"/>
  <img src="https://github.com/user-attachments/assets/f2140eda-114d-4911-84f4-035b8b5749be" width="220" alt="Application Settings Screen"/>
</p>

---

## Features

- **Vehicle Management:** Create, view, update, and manage vehicle records.
- **Vehicle Information:** Store essential details such as brand, model, chassis number, and other vehicle specifications.
- **Vehicle Images:** Attach and manage photos for individual vehicles.
- **Dashboard:** Access important vehicle statistics and an overview of managed cars.
- **Maintenance & Diagnostics:** Organize vehicle-related maintenance and diagnostic information.
- **Offline-First Storage:** Keep vehicle data available locally using SQLite.
- **Notifications & Reminders:** Support scheduled notifications for important updates.
- **Multilingual Support:** Full English and Arabic localization with RTL/LTR layouts.
- **Responsive UI:** Consistent layouts across different screen sizes.
- **Image & File Handling:** Support selecting vehicle images and managing files.

---

## Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter |
| Programming Language | Dart |
| Architecture | Clean Architecture, Feature-First |
| State Management | Flutter BLoC / Cubit |
| Dependency Injection | GetIt |
| Navigation | GoRouter |
| Local Database | Drift / SQLite |
| Local Storage | SharedPreferences |
| Responsive UI | Flutter ScreenUtil |
| Localization | Easy Localization |
| Notifications | Flutter Local Notifications |
| Image Selection | Image Picker |
| File Management | File Picker |

---

## Architecture & Engineering Practices

AutoDesk is structured around maintainability, scalability, and separation of responsibilities.

Key engineering practices include:

- Feature-First Project Organization.
- Clean Architecture principles.
- Repository Pattern.
- Separation of Concerns.
- Dependency Injection.
- Reactive State Management using BLoC / Cubit.
- Offline-First Application Design.
- Local Database Management with Drift.
- Database Schema Migrations.
- CRUD Operations.
- Responsive UI Development.
- Arabic RTL and English LTR Support.
- Unit and Widget Testing.

---

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

---

## Getting Started

### Prerequisites

Make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/johnadelm23-beep/auto_desk.git
```

**2. Navigate to the project directory**

```bash
cd auto_desk
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Generate database code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**5. Run the application**

```bash
flutter run
```

---

## Build APK

To generate a release APK:

```bash
flutter build apk --release
```

To generate separate APKs for different CPU architectures:

```bash
flutter build apk --release --split-per-abi
```

---

## Localization

AutoDesk supports two languages:

- **English:** Left-to-Right (LTR).
- **Arabic:** Right-to-Left (RTL).

The application adapts its layout and text direction based on the selected language.

---

## Database & Offline Support

AutoDesk uses **Drift**, a reactive persistence library built on top of SQLite, to manage local application data.

This provides:

- Persistent vehicle records.
- Local data access without an internet connection.
- Structured database queries.
- Database schema versioning and migrations.

---

## Project Status

AutoDesk is an ongoing private development project focused on building a structured and reliable vehicle management experience.

## License

This project is currently private. All rights reserved unless otherwise specified.

---

**Developed with Flutter & Dart.**
