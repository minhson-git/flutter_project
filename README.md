# 🎬 Movie Streaming App

A movie streaming application built with Flutter and Firebase, providing a smooth movie watching experience on mobile devices.

## ✨ Key Features

### 👤 User Management
- 🔐 Sign up/Sign in with Firebase Auth
- 👨‍💼 Personal profile management
- 🔒 Secure user information

### 🎭 Movie Content
- 📱 Responsive UI with Sizer
- 🎥 Video playback with full controls
- 🔍 Search and filter movies by category
- ⭐ Rate and favorite movies
- 📊 Movie statistics with charts

### 💾 Storage & Sync
- ☁️ Data synchronization with Cloud Firestore
- 📁 Media storage with Firebase Storage
- 💽 Local cache with Shared Preferences

## 🛠 Technologies Used

### Core Framework
- **Flutter**: ^3.7.2
- **Dart**: Programming Language

### Backend Services
- **Firebase Core**: ^3.6.0
- **Firebase Auth**: ^5.3.1
- **Cloud Firestore**: ^5.4.3
- **Firebase Storage**: ^12.3.2

### UI/UX Libraries
- **Sizer**: ^2.0.15 - Responsive design
- **Google Fonts**: ^6.1.0 - Typography
- **Cached Network Image**: ^3.3.1 - Image optimization
- **Flutter SVG**: ^2.0.9 - Vector graphics
- **FL Chart**: ^0.65.0 - Data visualization

### Media & Utilities
- **Video Player**: ^2.8.1 - Video streaming
- **Dio**: ^5.4.0 - HTTP client
- **Connectivity Plus**: ^5.0.2 - Network status
- **URL Launcher**: ^6.2.2 - External links
- **Fluttertoast**: ^8.2.4 - Notifications

## 📁 Project Structure

```
lib/
├── models/                 # Data models
│   ├── user_model.dart
│   ├── movie_model.dart
│   └── category_model.dart
├── services/              # Business logic
│   ├── auth_service.dart
│   ├── movie_service.dart
│   ├── data_init_service.dart
│   └── firestore_service.dart
├── presentation/          # UI components
│   ├── screens/
│   └── widgets/
└── firebase_options.dart  # Firebase config
```

## 🚀 Installation & Setup

### System Requirements
- Flutter SDK ^3.7.2
- Android Studio / VS Code
- Android SDK (API level 23+)
- Firebase project setup

### Installation Steps

1. **Clone repository**
```bash
git clone <repository-url>
cd flutter_project
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
- Create Firebase project at [Firebase Console](https://console.firebase.google.com)
- Add Android app with package name: `com.dev.flutter_project`
- Download `google-services.json` and place in `android/app/`
- Enable Authentication, Firestore, Storage

4. **Run the application**
```bash
flutter run
```

## 🔧 Firebase Configuration

### Authentication
- Enable Email/Password sign-in method
- Optional: Enable Google Sign-In

### Firestore Database
- Create database in test mode
- Configure security rules

### Storage
- Create default bucket
- Configure storage rules

## 📱 Screenshots

<!-- Add application screenshots here -->

## 🤝 Contributing

1. Fork the project
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Create Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Contact

- **Project Link**: [GitHub Repository](https://github.com/minhson-git/flutter_project)
- **Firebase Project**: `movie-app-181b2`

## 🔗 References

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)

---

⭐ **Star this repo if you