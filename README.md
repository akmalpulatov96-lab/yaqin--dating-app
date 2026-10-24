# Yaqin (Яқин) — Local Spontaneous Dating & Real-Time Meetups

Production-ready cross-platform mobile application developed with Flutter, Firebase Authentication, Cloud Firestore, and real-time GPS Geolocation.

## ✨ Core Features
1. **Authentication & Profile**:
   - Free Firebase Email/Password Authentication.
   - User Profile (Avatar, Name, Age, Bio, 3 tags).
   - **Stealth Mode** toggle (instantly hides coordinates and user from radar/map).
   - Dual interface localization: **Russian (RU)** and **Tajik (TG)**.
   - Dark and Light dynamic themes.

2. **Proximity Radar (Real-Time Background GPS)**:
   - Battery-optimized location tracking (`distanceFilter: 10m`, balanced accuracy).
   - Stationary Trigger Algorithm: triggers a match alert only when 2 users remain within **10–15 meters** of each other for **10–15 minutes**.
   - Tinder-style swipe card to like or pass.

3. **Interactive Map & Geo-Capsules**:
   - OpenStreetMap / Leaflet tile layer via `flutter_map`.
   - Leave time-limited capsules (lifespan: 1 to 5 hours).
   - Auto-deletion upon expiration.
   - Unlocked exclusively when physically located within **15–20 meters** radius.

4. **Exclusive "Phantom Capsules"**:
   - High-stakes urban quest drops marked with single-use flag.
   - Atomic Firestore transactions ensure that **only the very first user** walking within 15–20m can unlock it.
   - Instantly and permanently vanishes from the map for all other participants upon unlock.

5. **In-App Chat & Meetups**:
   - Real-time temporary messenger.
   - One-tap **"Share Meeting Pin"** (`📍 Точка встречи`) dropping direct coordinates into chat.

---

## 🚀 Setup & Firebase Configuration

### 1. Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.0.0+)
- Android Studio / Android SDK
- Physical Android devices or emulators

### 2. Firebase Project Setup
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Create a project named `Yaqin`.
3. Enable **Authentication** -> **Email/Password**.
4. Enable **Cloud Firestore** in Test/Production mode.
   - Recommended Firestore Rules:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /{document=**} {
           allow read, write: if request.auth != null;
         }
       }
     }
     ```
5. Register an Android App:
   - Android Package name: `com.yaqin.dating`
   - Download `google-services.json` and place it in:
     `YaqinApp/android/app/google-services.json`

---

## 📱 Testing on 2 Physical Android Devices

To test the proximity match trigger and phantom capsules:

1. Connect Device 1 via USB:
   ```bash
   flutter run -d <device-id-1>
   ```
   - Register User A (`user1@yaqin.app`).

2. Connect Device 2 via USB or install APK:
   ```bash
   flutter build apk --release
   flutter install -d <device-id-2>
   ```
   - Register User B (`user2@yaqin.app`).

3. **Testing Proximity Radar**:
   - Place both devices within 10–15 meters.
   - Leave them stationary for 10 minutes (or modify `stationaryTriggerMinutes` to 1 min for fast testing in `lib/services/proximity_engine.dart`).
   - The Tinder match card will pop up on both screens.

4. **Testing Phantom Capsule**:
   - From Device 1, tap `+` on the Map, toggle `Фантомная капсула`, set lifespan to 1 hour, and drop it.
   - Bring Device 2 within 15–20 meters and tap the purple marker to claim it.
   - Verify the capsule vanishes immediately and cannot be claimed again.
