// This file was manually created based on provided config.
// For full configuration, run 'flutterfire configure' after adding apps in Firebase console.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for ios - add the ios app in Firebase console and run flutterfire configure.');
      case TargetPlatform.macOS:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for macos - you can reconfigure this by running the FlutterFire CLI again.');
      case TargetPlatform.windows:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for windows - you can reconfigure this by running the FlutterFire CLI again.');
      case TargetPlatform.linux:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for linux - you can reconfigure this by running the FlutterFire CLI again.');
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: 'AIzaSyBD55eE6WaEKP2Pxa7i3LntV-HGdzj9Xzc',
      authDomain: 'hitagyana-clg-finder.firebaseapp.com',
      projectId: 'hitagyana-clg-finder',
      storageBucket: 'hitagyana-clg-finder.appspot.com',
      messagingSenderId: '688136540466',
      appId: '1:688136540466:web:cdac5d71e268de1031872b',
      measurementId: 'G-TL9YRXH0V7');

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBD55eE6WaEKP2Pxa7i3LntV-HGdzj9Xzc',
    appId: '1:688136540466:android:d6e2e8e6e5f5e7e531872b',
    messagingSenderId: '688136540466',
    projectId: 'hitagyana-clg-finder',
    storageBucket: 'hitagyana-clg-finder.appspot.com',
  );
}
