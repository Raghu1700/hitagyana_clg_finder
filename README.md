# Hitagyana College Finder

A modern Flutter application designed to help students find and compare colleges easily.

## Features

- **College Search**: Search and filter colleges based on various criteria
- **Detailed College Information**: View comprehensive details about each college including:
  - Courses offered
  - Facilities
  - Fee structure
  - Location and contact details
- **Save & Compare**: Save favorite colleges and compare them side by side
- **Extracurricular Activities**: Browse and discover extracurricular classes and activities
- **User Authentication**: Secure login and registration system
- **Modern UI**: Beautiful and intuitive user interface with custom theme colors:
  - Light Peach (#ffd3ac)
  - Rosy Pink (#ffb5ab)
  - Terracotta (#e39a7b)
  - Gold (#dbb06b)

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository
```bash
git clone https://github.com/Raghu1700/hitagyana_clg_finder.git
```

2. Navigate to project directory
```bash
cd hitagyana_clg_finder
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   └── app_export.dart
├── data/
│   ├── models/
│   └── services/
├── presentation/
│   ├── auth/
│   ├── college_details_screen/
│   ├── college_search_dashboard/
│   ├── extracurricular_classes_screen/
│   ├── onboarding_flow/
│   ├── saved_colleges_screen/
│   └── splash_screen/
├── routes/
├── theme/
└── widgets/
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details
