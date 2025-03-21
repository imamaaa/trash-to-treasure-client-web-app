import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart'; // Import overlay support
import 'landingPage.dart';
import 'login.dart';
import 'signup.dart';
import 'dashboard.dart';
import 'email_verification_page.dart';
import 'shop_details.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDEsRPmH3JBuxWrOo8A8UH-xX5vD_ZsL9s",
      authDomain: "trashtotreasure-4a540.firebaseapp.com",
      projectId: "trashtotreasure-4a540",
      storageBucket: "trashtotreasure-4a540.appspot.com",
      messagingSenderId: "228866710479",
      appId: "1:228866710479:web:7b18763b153da9eaee90ba",
      measurementId: "G-LED6WMRB15",
    ),
  );

  runApp(
    OverlaySupport.global( // Wrap the app in OverlaySupport
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  final AppRouteParser _routeParser = AppRouteParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trash to Treasure',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeParser,
    );
  }
}
