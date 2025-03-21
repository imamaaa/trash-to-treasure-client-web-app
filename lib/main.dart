import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart'; // Import overlay support
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'landingPage.dart';
import 'login.dart';
import 'signup.dart';
import 'dashboard.dart';
import 'email_verification_page.dart';
import 'shop_details.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Firebase using values from .env file
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
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
