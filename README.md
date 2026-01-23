# 🍽️ Food Safety Inspection & Reporting App

A comprehensive Flutter application designed to ensure food safety compliance through citizen reporting and professional inspections. This app empowers citizens to report food safety violations and enables inspectors to conduct thorough assessments using AI-powered analysis.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [API Integration](#api-integration)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## ✨ Features

### 👥 Citizen Features
- **Report Violations**: Submit detailed reports about food safety issues with photos
- **Real-time Location**: GPS-based location tracking for accurate reporting
- **Image Upload**: Support for multiple images with camera/gallery access
- **Anonymous Reporting**: Option to report anonymously
- **Report Tracking**: Monitor the status of submitted reports

### 🔍 Inspector Features
- **Professional Inspections**: Comprehensive checklist-based inspections
- **AI-Powered Analysis**: YOLOv8 integration for automated image analysis
- **Citizen Report Review**: Access and analyze citizen-submitted reports
- **Compliance Scoring**: Automated scoring based on FSSAI guidelines
- **Report Management**: Approve, reject, or escalate reports

### 🏢 Restaurant Management
- **Restaurant Profiles**: Detailed information about registered restaurants
- **Inspection History**: Track all past inspections and compliance records
- **Risk Assessment**: Automated risk scoring based on inspection results

## 🛠️ Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile and web development
- **Dart**: Programming language
- **Provider**: State management solution

### Backend & Services
- **RESTful APIs**: For data communication
- **Firebase**: Authentication and cloud storage
- **SQLite**: Local data storage

### AI & ML
- **YOLOv8**: Object detection for food safety violations
- **Computer Vision**: Image analysis and classification

### Development Tools
- **Android Studio / VS Code**: IDE
- **Git**: Version control
- **GitHub**: Repository hosting

## 📱 Screenshots

### Citizen Dashboard
- Report submission interface
- Image upload functionality
- Report status tracking

### Inspector Dashboard
- Inspection checklists
- Citizen reports review
- AI analysis results

### Restaurant Profiles
- Inspection history
- Compliance scores
- Risk assessments

## 🚀 Installation

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Git

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/SASI-20041230/food_safety_app.git
   cd food_safety_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure platform-specific settings**

   **For Android:**
   - Ensure Android SDK is properly configured
   - Add camera permissions in `android/app/src/main/AndroidManifest.xml`

   **For iOS:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Configure camera and photo library permissions

4. **Run the application**
   ```bash
   # For Android
   flutter run -d android

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d chrome
   ```

### Build Instructions

**Android APK:**
```bash
flutter build apk --release
```

**iOS App Store:**
```bash
flutter build ios --release
```

**Web Build:**
```bash
flutter build web --release
```

## 📖 Usage

### For Citizens
1. **Register/Login**: Create an account or login
2. **Browse Restaurants**: Find restaurants in your area
3. **Submit Reports**: Take photos and describe violations
4. **Track Progress**: Monitor report status and inspector responses

### For Inspectors
1. **Login**: Access inspector dashboard
2. **Review Reports**: Analyze citizen-submitted reports
3. **Conduct Inspections**: Use checklists for professional assessments
4. **AI Analysis**: Utilize automated image analysis
5. **Generate Reports**: Create detailed compliance reports

## 🏗️ Project Structure

```
food_safety_app/
├── android/                 # Android platform code
├── ios/                     # iOS platform code
├── lib/                     # Main Flutter application
│   ├── models/             # Data models
│   │   ├── inspection.dart
│   │   ├── report.dart
│   │   ├── restaurant.dart
│   │   └── user.dart
│   ├── providers/          # State management
│   │   ├── auth_provider.dart
│   │   ├── inspection_provider.dart
│   │   ├── report_provider.dart
│   │   └── restaurant_provider.dart
│   ├── screens/            # UI screens
│   │   ├── auth/           # Authentication screens
│   │   ├── citizen/        # Citizen user interface
│   │   ├── inspector/      # Inspector dashboard
│   │   └── admin/          # Admin interface
│   ├── services/           # API and utility services
│   │   ├── api_service.dart
│   │   └── mock_data.dart
│   └── config/             # Configuration files
│       └── constants.dart
├── test/                   # Unit and widget tests
├── web/                    # Web platform files
└── pubspec.yaml           # Flutter dependencies
```

## 🔌 API Integration

The app integrates with the following APIs:

### Food Safety APIs
- **FSSAI Compliance API**: Real-time compliance checking
- **Restaurant Database**: Centralized restaurant information
- **Inspection Records**: Historical inspection data

### AI Services
- **YOLOv8 API**: Object detection for food safety violations
- **Image Analysis**: Automated quality assessment
- **Risk Scoring**: Machine learning-based risk evaluation

### Authentication
- **Firebase Auth**: User authentication and authorization
- **Role-based Access**: Different permissions for citizens, inspectors, and admins

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Write comprehensive tests
- Update documentation
- Ensure cross-platform compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

**Project Developer**: SASI
- **GitHub**: [@SASI-20041230](https://github.com/SASI-20041230)
- **Email**: [your-email@example.com]
- **LinkedIn**: [Your LinkedIn Profile]

### Support
- Create an issue on GitHub for bug reports
- Use discussions for questions and feature requests
- Check the documentation for common solutions

---

⭐ **Star this repository** if you find it helpful!

**Made with ❤️ for Food Safety**
