// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  // TODO (codelab user): Replace with your Firebase credentials

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxC2kOguEy-Qf09iTPws3gc1qZD6jAIc8',
    appId: '1:450739637054:web:f11254e44247311a00fa6f',
    messagingSenderId: '450739637054',
    projectId: 'auction-b92c7',
    authDomain: 'auction-b92c7.firebaseapp.com',
    storageBucket: 'auction-b92c7.appspot.com',
    measurementId: 'G-JG4VR9K7D7',
  );

  // Generate this file with credentials with the FlutterFire CLI

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPe-x64LTZeIEn2EzVjcQFa8r-17TlDQ0',
    appId: '1:450739637054:android:69be0603fc4b2be600fa6f',
    messagingSenderId: '450739637054',
    projectId: 'auction-b92c7',
    storageBucket: 'auction-b92c7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8J09j398AQ57G_Q5nvs2Nf1hVTTVAM3Y',
    appId: '1:450739637054:ios:722841eef3dd98aa00fa6f',
    messagingSenderId: '450739637054',
    projectId: 'auction-b92c7',
    storageBucket: 'auction-b92c7.appspot.com',
    iosClientId:
        '450739637054-vum9d6j4asbb96ln9beva047det5l9li.apps.googleusercontent.com',
    iosBundleId: 'com.example.start',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD8J09j398AQ57G_Q5nvs2Nf1hVTTVAM3Y',
    appId: '1:450739637054:ios:722841eef3dd98aa00fa6f',
    messagingSenderId: '450739637054',
    projectId: 'auction-b92c7',
    storageBucket: 'auction-b92c7.appspot.com',
    iosClientId:
        '450739637054-vum9d6j4asbb96ln9beva047det5l9li.apps.googleusercontent.com',
    iosBundleId: 'com.example.start',
  );
}
