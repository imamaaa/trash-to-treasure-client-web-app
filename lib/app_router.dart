import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landingPage.dart';
import 'login.dart';
import 'signup.dart';
import 'dashboard.dart';
import 'shop_details.dart';
import 'email_verification_page.dart';
import 'enter_pin.dart';
import 'history.dart';
import 'landingPage.dart';
import 'opt_success.dart';
import 'otp_fail.dart';
import 'profile_settings.dart';
import 'scan_qr.dart';

// Class to represent the current page configuration
class PageConfig {
  final String path;
  final Map<String, dynamic>? params;

  const PageConfig(this.path, {this.params});
}

// Route Information Parser
class AppRouteParser extends RouteInformationParser<PageConfig> {
  @override
  Future<PageConfig> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '/');
    // Extract the path
    if (uri.pathSegments.isEmpty) return PageConfig('/');
    final path = '/' + uri.pathSegments.join('/');
    return PageConfig(path);
  }

  @override
  RouteInformation restoreRouteInformation(PageConfig config) {
    return RouteInformation(location: config.path);
  }
}

// Router Delegate for handling navigation
class AppRouterDelegate extends RouterDelegate<PageConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageConfig> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String currentPath = '/'; // Default route path
  Map<String, dynamic>? params;

  final Set<String> publicRoutes = {
    '/',  // Landing page
    '/login',
    '/signup',
    '/otp_fail',
    '/opt_success',
    '/shop_details',
    '/email_verification',
  };

  AppRouterDelegate();

  bool _isPublicRoute(String path) {
    return publicRoutes.contains(path);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (currentPath == '/') MaterialPage(child: LandingPage()),
        if (currentPath == '/login') MaterialPage(child: LoginPage()),
        if (currentPath == '/signup') MaterialPage(child: SignUpPage()),
        if (currentPath == '/email_verification')
          MaterialPage(
            child: EmailVerificationPage(
              email: params?['email'] ?? '',
              firstName: params?['firstName'] ?? '',
              lastName: params?['lastName'] ?? '',
            ),
          ),
        if (currentPath == '/shop_details') MaterialPage(child: ShopDetailsPage()),
        if (currentPath == '/dashboard') MaterialPage(child: Dashboard()),
        if (currentPath == '/otp_fail') MaterialPage(child: OTPFailPage()),
        if (currentPath == '/opt_success') MaterialPage(child: OTPSuccessPage()),
        if (currentPath == '/scan_qr') MaterialPage(child: QRScannerPage()),
        if (currentPath == '/enter_pin') MaterialPage(child: EnterPinPage()),
        if (currentPath == '/history') MaterialPage(child: ShopHistoryPage(routerDelegate: this)),
        if (currentPath == '/profile_settings') MaterialPage(child: ProfileSettingsPage(routerDelegate: this)),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;

        // Redirect to login if current path is protected and user is not authenticated
        if (!_isPublicRoute(currentPath) && FirebaseAuth.instance.currentUser == null) {
          navigateTo('/login');
        }

        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PageConfig config) async {
    if (!_isPublicRoute(config.path) && FirebaseAuth.instance.currentUser == null) {
      navigateTo('/login');
    } else {
      currentPath = config.path;
      params = config.params;
      notifyListeners();
    }
  }

  void navigateTo(String path, {Map<String, dynamic>? params}) {
    if (!_isPublicRoute(path) && FirebaseAuth.instance.currentUser == null) {
      currentPath = '/login';
    } else {
      currentPath = path;
      this.params = params;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      navigateTo('/login');
    } catch (e) {
      print("Logout error: $e");
    }
  }

  @override
  PageConfig get currentConfiguration => PageConfig(currentPath, params: params);
}

