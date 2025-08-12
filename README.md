# Notes App

A modern, cross-platform notes application built with Flutter.

## Features

- **Create, Edit, and Delete Notes**
  - Add new notes instantly
  - Edit existing notes with undo/redo support
  - Delete single or multiple notes with selection mode

- **Persistent Storage**
  - All notes are saved locally using SQLite
  - Notes are auto-saved and changes are cached for reliability

- **Search**
  - Search notes by title or body text

- **Pull-to-Refresh**
  - Pull down on the notes list to refresh and sync with the database

- **Undo/Redo Editing**
  - Undo and redo changes while editing note content

- **Multi-Select, Batch Delete, and Batch Share**
  - Long-press to select multiple notes and delete them in one action
  - Share multiple selected notes at once

- **Responsive UI & Theming**
  - Light and dark mode support
  - Adaptive layout for mobile and desktop

- **Custom App Icon & Splash Screen**
  - Branded app icon and splash screen for a polished look

## Getting Started

1. Clone this repository
2. Run `flutter pub get`
3. Run the app on your device or emulator: `flutter run`

## Build for Production

- **Android APK:** `flutter build apk --release`
- **Web:** `flutter build web --release`
- **Linux/Windows:** `flutter build linux --release` or `flutter build windows --release`

## Dependencies
- Flutter
- sqflite
- shared_preferences
- fluttertoast
- flutter_launcher_icons
- flutter_native_splash

---

Feel free to contribute or open issues for suggestions and bug reports!
