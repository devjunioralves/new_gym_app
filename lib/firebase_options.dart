// Este arquivo será gerado automaticamente pelo FlutterFire CLI
// Execute: flutterfire configure
// Por enquanto, este é um placeholder

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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Substitua com suas configurações reais do Firebase

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7a71m4SkTVNxSQLzo2m1LvPyNRKxUzEg',
    appId: '1:310316534784:web:ca050477f7949a4d401ce5',
    messagingSenderId: '310316534784',
    projectId: 'newgymapp-f3667',
    authDomain: 'newgymapp-f3667.firebaseapp.com',
    storageBucket: 'newgymapp-f3667.firebasestorage.app',
    measurementId: 'G-MX4WLLK3Q8',
  );

  // Execute: flutterfire configure

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASgFoTspHWq6CfnFco_5WlAnwAriiGnD0',
    appId: '1:310316534784:android:a72909d17c787d8b401ce5',
    messagingSenderId: '310316534784',
    projectId: 'newgymapp-f3667',
    storageBucket: 'newgymapp-f3667.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDpEk0idvESWcNfkMlTMr9p8F_GfJ-i7V8',
    appId: '1:310316534784:ios:44e4a06d5d88e617401ce5',
    messagingSenderId: '310316534784',
    projectId: 'newgymapp-f3667',
    storageBucket: 'newgymapp-f3667.firebasestorage.app',
    iosBundleId: 'com.example.newGymApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDpEk0idvESWcNfkMlTMr9p8F_GfJ-i7V8',
    appId: '1:310316534784:ios:44e4a06d5d88e617401ce5',
    messagingSenderId: '310316534784',
    projectId: 'newgymapp-f3667',
    storageBucket: 'newgymapp-f3667.firebasestorage.app',
    iosBundleId: 'com.example.newGymApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB7a71m4SkTVNxSQLzo2m1LvPyNRKxUzEg',
    appId: '1:310316534784:web:8f121d2eabdb36ba401ce5',
    messagingSenderId: '310316534784',
    projectId: 'newgymapp-f3667',
    authDomain: 'newgymapp-f3667.firebaseapp.com',
    storageBucket: 'newgymapp-f3667.firebasestorage.app',
    measurementId: 'G-RJNWYSWZX2',
  );
}
