// File generated from your google-services.json - Oday Phone
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC80zQpeUz8C_eHfOInDTaXAjYHrgyXnzY',
    appId: '1:389995408138:android:7abaeefb31ac78c2d3e8f3',
    messagingSenderId: '389995408138',
    projectId: 'addy-phone-906bf',
    storageBucket: 'addy-phone-906bf.firebasestorage.app',
  );
}
