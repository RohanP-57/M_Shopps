# Mini Shopping App 🛒

A modern Flutter e-commerce application with Firebase integration, featuring Google authentication, real-time order management, and multiple payment options.

## 📱 Screenshots

[](screenshots/ss1.png) 
[](screenshots/ss2.png)
[](screenshots/ss3.png)
[](screenshots/ss4.png)
[](screenshots/ss5.png)
[](screenshots/ss6.png)
[](screenshots/ss7.png)
[](screenshots/ss8.png)
[](screenshots/ss9.png)
[](screenshots/ss10.png)
[](screenshots/ss11.png)
[](screenshots/ss12.png)
[](screenshots/ss13.png)

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
