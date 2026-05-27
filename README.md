# Quick Notes

A production-quality dark-themed collaborative notes and file storage Flutter app for Android and Web.

## Features

- **Authentication** — Username/password login with no email required. Sessions expire at midnight and logout invalidates all devices instantly.
- **Notes** — Rich text editing (Quill editor), real-time sync across devices, custom backgrounds (color or image), pinning, search, sort, offline support.
- **Files** — Upload any file type up to 100 MB, grid/list view toggle, rename, delete, download, real-time metadata sync.
- **Dark Theme** — Discord-inspired dark UI with Material 3 design.
- **Responsive** — Bottom navigation on mobile, sidebar on wide screens/web.

## Tech Stack

| Layer | Package |
|---|---|
| State management | flutter_riverpod |
| Navigation | go_router |
| Rich text | flutter_quill |
| File picking | file_picker |
| Storage | firebase_storage |
| Database | cloud_firestore |
| Auth | firebase_auth |
| Local cache | shared_preferences |

---

## Prerequisites

- Flutter SDK ≥ 3.7.2
- A Firebase project with Authentication, Firestore, Storage, and Hosting enabled

---

## Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Enable **Authentication** → Sign-in method → **Email/Password**.
3. Create a **Firestore** database in production mode.
4. Enable **Firebase Storage**.
5. (Optional) Enable **Firebase Hosting** for web deployment.

### 2. Add Firebase Configuration

Replace the placeholder values in `lib/services/firebase_service.dart`:

```dart
// Web — Firebase Console > Project Settings > Web app
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
);

// Android — Firebase Console > Project Settings > Android app
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
);
```

Alternatively for Android, download `google-services.json` and place it in `android/app/`.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
# Android
flutter run

# Web (Chrome)
flutter run -d chrome
```

---

## Deploy Firebase Security Rules

```bash
npm install -g firebase-tools
firebase login
```

Update `.firebaserc` with your actual project ID, then:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

---

## Build Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Deploy to Firebase Hosting (Web)

```bash
flutter build web --release
firebase deploy --only hosting
```

Live at: `https://YOUR_PROJECT_ID.web.app`

---

## Architecture

```
lib/
├── main.dart
├── services/
│   ├── firebase_service.dart    # Firebase options (replace with your config)
│   └── storage_service.dart     # SharedPreferences provider
├── core/
│   ├── constants/               # Collection names, limits
│   ├── theme/                   # Discord dark Material 3 theme
│   ├── errors/                  # Sealed exception hierarchy
│   └── utils/                   # Date formatting, file utilities
├── routing/app_router.dart      # GoRouter with session-based redirect
├── shared/widgets/              # Shimmer, empty state, error, dialogs
└── features/
    ├── auth/                    # Login, register, profile screens
    ├── session/                 # Midnight expiry + cross-device logout
    ├── notes/                   # Quill editor, real-time sync, backgrounds
    └── files/                   # Upload, download, grid/list view
```

### Session Management

- Sessions are stored in Firestore `sessions/{sessionId}` with `expiresAt` = next local midnight.
- Each user doc has `sessionVersion`. On logout, it increments — invalidating all sessions on all devices.
- A `Timer` in `SessionNotifier` fires at midnight to force re-validation.

### Username Authentication

Firebase Auth requires email. The app uses a synthetic email: `{username}@quicknotes.app`. The real username lives in Firestore `users/{uid}`. Users only ever see their username.

---

## Firestore Data Model

| Collection | Key fields |
|---|---|
| `users/{uid}` | uid, username, sessionVersion, createdAt, lastLoginAt |
| `sessions/{sessionId}` | sessionId, uid, sessionVersion, expiresAt |
| `notes/{noteId}` | uid, title, content (Quill Delta JSON), contentPlain, isPinned, backgroundType, backgroundColor, backgroundImageUrl, createdAt, updatedAt |
| `files/{fileId}` | uid, name, storagePath, downloadUrl, sizeBytes, mimeType, createdAt, updatedAt |

## Firebase Storage Paths

```
notes/{uid}/{noteId}/background    — note background images
files/{uid}/{fileId}/{filename}    — uploaded user files
```
flutter build web --release
firebase deploy --only hosting