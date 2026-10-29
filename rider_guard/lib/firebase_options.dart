// File ini di-generate otomatis oleh: flutterfire configure
// Jalankan perintah tersebut setelah setup Firebase project Anda
// 
// Cara setup:
// 1. Buat project di https://console.firebase.google.com
// 2. Install FlutterFire CLI: dart pub global activate flutterfire_cli
// 3. Jalankan: flutterfire configure
// File ini akan ter-generate otomatis dengan data asli Anda

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
            'Platform ini tidak didukung. Jalankan: flutterfire configure');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAFqDA5jO_SFqfiGIxhtCEkuLG_fMsPoj8',
    appId: '1:369774268229:web:b94a51c0e2e10e6e05782c',
    messagingSenderId: '369774268229',
    projectId: 'rider-guard-fef71',
    authDomain: 'rider-guard-fef71.firebaseapp.com',
    storageBucket: 'rider-guard-fef71.firebasestorage.app',
    measurementId: 'G-WJ3EJ40M06',
  );

  // ⚠️ GANTI DENGAN DATA ASLI DARI: flutterfire configure

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkwOzO5htdO6gJmW7Bg3XgVrIGKegYxdY',
    appId: '1:369774268229:android:4b9e65b779c702bf05782c',
    messagingSenderId: '369774268229',
    projectId: 'rider-guard-fef71',
    storageBucket: 'rider-guard-fef71.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAu5hllmoHMJxFYa_CBeH-fWZUKSKZjCGQ',
    appId: '1:369774268229:ios:46021991ac5f609205782c',
    messagingSenderId: '369774268229',
    projectId: 'rider-guard-fef71',
    storageBucket: 'rider-guard-fef71.firebasestorage.app',
    iosBundleId: 'com.example.riderGuard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAu5hllmoHMJxFYa_CBeH-fWZUKSKZjCGQ',
    appId: '1:369774268229:ios:46021991ac5f609205782c',
    messagingSenderId: '369774268229',
    projectId: 'rider-guard-fef71',
    storageBucket: 'rider-guard-fef71.firebasestorage.app',
    iosBundleId: 'com.example.riderGuard',
  );

}