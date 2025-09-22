# 📚 ReadVerse - Beautiful eBook Reader

<div align="center">
  <img src="assets/images/app_icon.png" alt="ReadVerse Logo" width="100" height="100">
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)
</div>

## 🌟 Overview

ReadVerse is a beautiful, feature-rich cross-platform eBook reader built with Flutter. Experience your digital library like never before with stunning themed backgrounds, gorgeous SVG book covers, and an intuitive reading interface that adapts to your preferences.

## ✨ Key Features

### 📖 Reading Experience
- **Multi-format Support**: PDF, EPUB, and TXT files
- **Beautiful Book Covers**: Custom SVG covers for every book genre
- **Progress Tracking**: Never lose your place with automatic bookmarking
- **Reading Analytics**: Track your reading time and progress

### 🎨 Stunning Themes
Choose from 7 carefully crafted themes, each with unique animated backgrounds:

- **🎭 Classic** - Elegant purple gradients with geometric patterns
- **🌊 Ocean Breeze** - Serene blues with animated waves and bubbles  
- **🌲 Forest Dream** - Natural greens with floating leaves and sunbeams
- **🌅 Sunset Glow** - Warm oranges with dynamic sun rays and clouds
- **🌙 Midnight Sky** - Deep blues with twinkling stars and constellations
- **🌸 Rose Gold** - Elegant pinks with shimmering particles
- **🌈 Aurora** - Mystical purples with flowing northern lights

### 🔥 Advanced Features
- **Firebase Authentication**: Secure user accounts
- **Cloud Sync**: Access your library across devices
- **Smart Search**: Find books by title, author, or content
- **Favorites System**: Mark and organize your favorite books
- **Reading Statistics**: Detailed insights into your reading habits
- **Responsive Design**: Perfect on phones and tablets

## 🛠️ Technology Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider Pattern
- **Graphics**: Custom SVG Assets, Animated Backgrounds
- **File Support**: flutter_pdfview, epubx
- **Authentication**: Firebase Auth
- **Storage**: SharedPreferences, Cloud Firestore

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase Account
- Android/iOS development setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/readverse.git
   cd readverse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication and Firestore
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

4. **Run the app**
   ```bash
   flutter run
   ```

### Project Structure
```
lib/
├── models/           # Data models (Book, User, etc.)
├── providers/        # State management
├── screens/          # UI screens
├── widgets/          # Reusable widgets
├── services/         # Firebase and other services
├── utils/            # Helper functions and utilities
└── main.dart         # App entry point

assets/
├── images/           # App images and icons
│   ├── book_covers/  # SVG book covers
│   └── backgrounds/  # Theme backgrounds
└── books/            # Sample books and manifest
```

## 🎨 Custom Themes

Each theme includes:
- **Dynamic Gradients**: Smooth color transitions
- **Animated Elements**: Floating particles, waves, stars
- **Interactive Effects**: Subtle parallax and breathing animations
- **Consistent UI**: Colors and styling that match the theme

## 📚 Book Management

### Supported Formats
- **PDF**: Full reading support with zoom and navigation
- **EPUB**: Reflowable text with custom styling
- **TXT**: Clean text reading with custom fonts

### Custom Book Covers
Each book automatically gets a beautiful SVG cover based on:
- Genre detection from title/content
- Consistent color schemes
- Professional typography
- Scalable vector graphics

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Shubham && Deep **

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- The open-source community for inspiration
- All contributors and testers

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
  <p>⭐ Star this repo if you found it helpful!</p>
</div>
