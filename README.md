# Mini Shopping App 🛒

A modern Flutter e-commerce application with Firebase integration, featuring Google authentication, real-time order management, and multiple payment options.

## 📱 Screenshots

![Screen1](screenshots/ss(1).png)
![Screen2](screenshots/ss(2).png)
![Screen3](screenshots/ss(3).png)
![Screen4](screenshots/ss(4).png)
![Screen5](screenshots/ss(5).png)
![Screen6](screenshots/ss(6).png)
![Screen7](screenshots/ss(7).png)
![Screen8](screenshots/ss(8).png)
![Screen9](screenshots/ss(9).png)
![Screen10](screenshots/ss(10).png)
![Screen11](screenshots/ss(11).png)
![Screen12](screenshots/ss(12).png)
![Screen13](screenshots/ss(13).png)



## ✨ Features

### 🔐 Authentication
- **Google Sign-In** integration
- **Firebase Authentication** with real-time auth state management
- **User Profile Management** with username setup
- **Secure Session Management**

### 🛍️ Shopping Experience
- **Product Catalog** with CSV data loading
- **Shopping Cart** with add/remove functionality
- **Real-time Cart Updates** with quantity management
- **Product Search & Filtering**

### 📍 Address Management
- **Dynamic Location Services** with country/state selection
- **Address Storage** in user profiles
- **Default Address Management**
- **Address Validation** with form validation

### 💳 Payment Integration
- **Multiple Payment Methods:**
  - UPI Payment (simulated)
  - Razorpay Integration (test mode)
  - Cash on Delivery (COD)
- **Payment Method Tracking** in user profiles and orders
- **Secure Payment Processing**

### 📦 Order Management
- **Real-time Order Creation** with auto-generated IDs
- **Order History** with status tracking
- **Order Details** with item breakdown
- **Delivery Address Management**

### 🔥 Firebase Integration
- **Firestore Database** for real-time data storage
- **User Collection** with addresses and payment preferences
- **Orders Collection** with complete order tracking
- **Security Rules** for data protection

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/
│   ├── cart.dart              # Shopping cart management
│   └── product.dart           # Product data model
├── screens/
│   ├── auth_screen.dart       # Authentication UI
│   ├── auth_wrapper.dart      # Auth state management
│   ├── checkout_screen.dart   # Checkout process
│   ├── home_screen.dart       # Main dashboard
│   ├── order_confirmation_screen.dart
│   ├── product_list_screen.dart
│   └── summary_screen.dart
├── services/
│   ├── auth_service.dart      # Firebase Authentication
│   ├── firestore_service.dart # Database operations
│   ├── location_service.dart  # Location/address services
│   ├── payment_service.dart   # Payment processing
│   └── services.dart          # Service exports
├── firebase_options.dart      # Firebase configuration
└── main.dart                  # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.8.1)
- Firebase Project
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/mini-shopping-app.git
   cd mini-shopping-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

4. **Add your Firebase project**
   - Select your Firebase project
   - Choose platforms (Android, iOS, Web)
   - This will generate `firebase_options.dart`

5. **Configure Google Sign-In**
   - Get SHA-1 fingerprint: `cd android && ./gradlew signingReport`
   - Add SHA-1 to Firebase Console → Project Settings → Your Apps
   - Download updated `google-services.json`

6. **Update Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /orders/{orderId} {
         allow read: if request.auth != null && request.auth.uid == resource.data.userId;
         allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
         allow update: if request.auth != null && request.auth.uid == resource.data.userId;
       }
     }
   }
   ```

7. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Firebase Configuration
- Enable Authentication → Google Sign-In
- Create Firestore Database
- Set up Security Rules
- Add SHA-1 fingerprints for Android

### Environment Setup
- Add product data to `assets/data/products.csv`
- Configure location services for address management
- Set up payment gateway credentials (for production)

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.32.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.17.5
  google_sign_in: ^6.3.0
  provider: ^6.1.1
  csv: ^6.0.0
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Test Coverage
- Authentication flow testing
- Cart functionality testing
- Order creation testing
- Payment flow testing

## 🚀 Deployment

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

### Web
```bash
# Build Web
flutter build web --release
```

## 🔒 Security

- **Firebase Security Rules** for data protection
- **Authentication Required** for all user operations
- **Input Validation** on all forms
- **Secure Payment Processing** with test mode
- **User Data Encryption** in transit and at rest

## 🐛 Known Issues

- Firebase web compatibility issues with some packages
- Google Sign-In type casting warnings (non-blocking)
- NDK version warnings (cosmetic)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- Google Sign-In for authentication
- Community contributors and testers

## 📞 Support

If you have any questions or need help with setup, please:
1. Check the [Issues](https://github.com/yourusername/mini-shopping-app/issues) page
2. Create a new issue with detailed description
3. Contact the maintainer

---

**Made with ❤️ using Flutter & Firebase**
