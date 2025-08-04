# 🎓 Hitagyana College Finder

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**Find Your Perfect College** - A comprehensive college finder app built with Flutter and Firebase.

## 📱 Download APK

**[Download Latest APK (v1.0.0)](./Hitagyana-College-Finder-v1.0.0.apk)** - 53MB

> **Note**: Enable "Install from Unknown Sources" in your Android settings to install the APK.

## ✨ Features

### 🔐 **Authentication**
- Email/Password registration and login
- Secure Firebase Authentication
- User profile management with username support
- Account settings and preferences

### 🏫 **College Discovery**
- Search and filter colleges by name, location, courses
- Category-based college filtering
- Detailed college information with photos
- Real-time data from Firebase Firestore

### ❤️ **Save & Compare**
- Save favorite colleges
- Compare multiple colleges
- Persistent saved data across devices
- Export your saved colleges data

### 📞 **Contact & Navigation**
- **Visit Website**: Direct links to college websites
- **Make Calls**: One-tap calling to college phone numbers
- **Send Emails**: Pre-filled email forms for inquiries
- **Get Directions**: Google Maps integration for navigation

### 👤 **Profile Management**
- Edit profile information
- Change password securely
- Account settings and notifications
- Help & support options
- FAQ and bug reporting

### 🎨 **Beautiful UI**
- Stunning purple gradient theme
- Responsive design for all screen sizes
- Smooth animations and transitions
- Modern Material Design principles

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Raghu1700/hitagyana_clg_finder.git
   cd hitagyana_clg_finder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication and Firestore
   - Download `google-services.json` and place it in `android/app/`
   - Update Firebase configuration in the app

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter with Dart
- **Backend**: Firebase (Authentication + Firestore)
- **State Management**: StatefulWidget with setState
- **UI Framework**: Material Design with custom theming
- **Navigation**: Named routes with MaterialPageRoute

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── services/                 # Firebase services
│   ├── auth_service.dart
│   ├── firebase_service.dart
│   └── user_service.dart
├── presentation/             # UI screens
│   ├── auth/
│   ├── college_details_screen/
│   ├── college_search_dashboard/
│   └── saved_colleges_screen/
├── theme/                    # App theming
└── routes/                   # Navigation routes
```

## 🔥 Firebase Configuration

The app uses Firebase for:
- **Authentication**: User registration/login
- **Firestore**: College data storage and user profiles
- **Real-time Updates**: Live data synchronization

### Collections Structure
```
colleges/
├── name, location, ranking
├── fees, courses, facilities
├── contact, website
└── images, ratings

users/
├── uid, email, username
├── savedColleges[]
├── preferences
└── timestamps
```

## 📸 Screenshots

| Authentication | Saved Colleges | College Details | Profile |
|:---:|:---:|:---:|:---:|
| ![Auth](https://via.placeholder.com/200x400?text=Auth) | ![Saved](https://via.placeholder.com/200x400?text=Saved) | ![Details](https://via.placeholder.com/200x400?text=Details) | ![Profile](https://via.placeholder.com/200x400?text=Profile) |

## 🛠️ Build Instructions

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```
The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## 🎯 Key Features Implemented

- ✅ Firebase Authentication with email/password
- ✅ Real-time college data from Firestore
- ✅ Save/unsave colleges functionality
- ✅ Search and filter colleges
- ✅ College details with contact integration
- ✅ User profile management
- ✅ Website, phone, email, maps integration
- ✅ Beautiful purple gradient UI theme
- ✅ Responsive design for all devices
- ✅ No splash screen for instant access

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- 📧 Email: support@hitagyana.com
- 📱 Phone: +1-800-HITAGYANA
- 🐛 Issues: [GitHub Issues](https://github.com/Raghu1700/hitagyana_clg_finder/issues)

## 🙏 Acknowledgments

- Firebase for backend services
- Flutter team for the amazing framework
- Material Design for UI guidelines
- All contributors and testers

---

**Made with ❤️ using Flutter and Firebase**

*Last Updated: January 2025*
