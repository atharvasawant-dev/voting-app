import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are configured for Flutter Web in this project. '
      'Run FlutterFire CLI if you want to support additional platforms.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDmXd84Mo5MEmFK-adBFtV4jmxL6DMX9hI',
    appId: '1:264945885790:web:ae45508f63219975bc0acf',
    messagingSenderId: '264945885790',
    projectId: 'voting-app-b1e24',
    authDomain: 'voting-app-b1e24.firebaseapp.com',
    storageBucket: 'voting-app-b1e24.firebasestorage.app',
  );
}
