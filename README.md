# Pharmacy Engagement System (PharmaCareAI)

A Flutter-based mobile application designed to improve pharmacy-patient engagement, medication adherence, and communication through digital tools such as reminders, prescription management, and AI-assisted support.

---

## 📱 Project Overview

PharmaCareAI is a mobile application built using **Flutter** and integrated with **Firebase services**. It helps users manage prescriptions, receive medication reminders, and interact with an AI-powered assistant for better medication adherence.

The system is designed for real-world deployment on Android devices and supports authentication, cloud database storage, and notification services.

---

## ✨ Features

* 🔐 User Authentication (Google Sign-In & Email/Password)
* 💊 Prescription Management (Add, View, Update, Delete)
* ⏰ Medication Reminder System (Local Notifications)
* ☁️ Firebase Firestore Database Integration
* 🤖 AI Chat Assistant (Pharmacy Guidance Support)
* 📊 User-friendly Mobile UI
* 📱 Real Device Deployment (APK installation)

---

## 🛠️ Tech Stack

* Flutter (Dart)
* Firebase Authentication
* Cloud Firestore
* Firebase Google Sign-In
* Android SDK
* Local Notifications

---

## 📂 Project Structure

```
pharmacy_system/
├── android/
├── ios/
├── lib/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── main.dart
├── assets/
├── pubspec.yaml
└── README.md
```

---

## 🚀 Installation & Setup

### 1. Clone the repository

```bash
git clone https://github.com/tanyouchun/pharmacy-system.git
cd pharmacy-system
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

* Add your Firebase project
* Download `google-services.json`
* Place it in:

  ```
  android/app/
  ```
* Ensure package name matches Firebase configuration

### 4. Run the application

```bash
flutter run
```

---

## 📦 Build Release APK (Deployment)

To generate a production APK:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

APK output location:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📲 Deployment

The application is deployed on a **real Android device** by installing the generated APK. This demonstrates successful integration with real-world environments including Firebase services and Android system features.

---

## 🔐 Firebase Authentication Note

If Google Sign-In shows `ApiException: 10`, ensure:

* SHA-1 fingerprint is added in Firebase Console
* `google-services.json` matches package name
* Both debug and release SHA-1 are registered

---

## 📌 Future Improvements

* iOS deployment
* Doctor/pharmacist dashboard
* Cloud scheduling for reminders
* Enhanced AI recommendation system

---

## 👨‍💻 Author

Developed as Final Year Project (FYP)

---

## 📄 License

This project is for academic purposes.
