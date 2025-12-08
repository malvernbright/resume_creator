# Resume Creator

A modern, offline-first Flutter mobile application for creating professional Curriculum Vitaes (CVs) and Resumes with PDF and MS Word export functionality.

## Features

- ✨ **Offline-First Architecture**: All data is stored locally using SQLite, ensuring the app works without internet
- 🔐 **Firebase Authentication**: Secure user authentication and account management
- 📄 **Multiple Document Types**: Create both Resumes and CVs with different formatting
- 📊 **Comprehensive Sections**:
  - Personal Information
  - Professional Experience
  - Education History
  - Skills & Proficiencies
  - Projects & Portfolio
  - Achievements & Certifications
  - Languages
  - References
- 💾 **Export Options**: Generate PDF and MS Word documents
- 🎨 **Modern UI/UX**: Clean, intuitive interface with Material Design 3
- 🏗️ **Clean Architecture**: BLoC pattern for state management, Repository pattern for data handling

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: BLoC (flutter_bloc)
- **Local Database**: SQLite (sqflite)
- **Authentication**: Firebase Auth
- **PDF Generation**: pdf, syncfusion_flutter_pdf
- **Document Export**: syncfusion_flutter_xlsio (for Word documents)
- **UI**: Google Fonts, Material Design 3

## Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── errors/          # Error handling (Failures, Exceptions)
│   ├── themes/          # App themes and styling
│   └── utils/           # Utility functions (PDF generation, etc.)
├── data/
│   ├── datasources/
│   │   ├── local/       # Local database operations
│   │   └── remote/      # Firebase operations
│   ├── models/          # Data models with JSON serialization
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Business entities
│   └── repositories/    # Repository interfaces
└── presentation/
    ├── bloc/           # BLoC state management
    ├── screens/        # UI screens
    └── widgets/        # Reusable widgets
```

## Getting Started

### Prerequisites

- Flutter SDK (3.10.3 or higher)
- Dart SDK
- Firebase project configured
- iOS/Android development environment

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd resume_creator
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:

   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Download and add configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. Run `flutterfire configure` to generate Firebase options

## Building for Production

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

## Features Roadmap

- [x] User authentication
- [x] Local database storage
- [x] Resume/CV creation
- [x] PDF export
- [ ] MS Word export implementation
- [ ] Multiple resume templates
- [ ] Cloud backup/sync
- [ ] Share functionality
- [ ] Resume preview
- [ ] Form validation improvements
- [ ] Desktop support (macOS, Windows, Linux)

## Architecture

This project follows Clean Architecture principles:

- **Presentation Layer**: UI and state management (BLoC)
- **Domain Layer**: Business logic and entities
- **Data Layer**: Data sources and repository implementations

Benefits:

- Separation of concerns
- Testability
- Maintainability
- Scalability

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Malvern Bright

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication services
- Syncfusion for PDF/Word generation packages

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
