
// This file is a placeholder.
// You MUST run checking `flutterfire configure` in your terminal to replace this file with the real configuration.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseOptions have not been configured for linux - '
          'you need to run `flutterfire configure` in your terminal.',
        );
      default:
        throw UnsupportedError(
          'FirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBSCW-8ar37YVn6aQSKX-XSE7PN3rLit1I',
    appId: '1:802619782628:web:bc3bbdaa61384e7de403f1',
    messagingSenderId: '802619782628',
    projectId: 'sal7ny-6899a',
    authDomain: 'sal7ny-6899a.firebaseapp.com',
    storageBucket: 'sal7ny-6899a.firebasestorage.app',
    measurementId: 'G-MEF4Q2RB94',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDbOS13vJAr-kJZTigsaNef4m4WDYc-pjw',
    appId: '1:802619782628:ios:37161325eee7fadae403f1',
    messagingSenderId: '802619782628',
    projectId: 'sal7ny-6899a',
    storageBucket: 'sal7ny-6899a.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication3',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDbOS13vJAr-kJZTigsaNef4m4WDYc-pjw',
    appId: '1:802619782628:ios:37161325eee7fadae403f1',
    messagingSenderId: '802619782628',
    projectId: 'sal7ny-6899a',
    storageBucket: 'sal7ny-6899a.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3Xw6nMqKs0Zn3KSokVQ20xvLtMsQzjWE',
    appId: '1:802619782628:android:68bcd23389fd7400e403f1',
    messagingSenderId: '802619782628',
    projectId: 'sal7ny-6899a',
    storageBucket: 'sal7ny-6899a.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBSCW-8ar37YVn6aQSKX-XSE7PN3rLit1I',
    appId: '1:802619782628:web:d24240d0316d0067e403f1',
    messagingSenderId: '802619782628',
    projectId: 'sal7ny-6899a',
    authDomain: 'sal7ny-6899a.firebaseapp.com',
    storageBucket: 'sal7ny-6899a.firebasestorage.app',
    measurementId: 'G-CV988R9D9Y',
  );

}