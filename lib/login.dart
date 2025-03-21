import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_router.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // Helper function to validate email
  bool _validateEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Sign-in logic using Firebase Authentication
  Future<void> _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (!_validateEmail(email)) {
      _showErrorDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog("Empty Password", "Please enter your password.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Try to sign in with Firebase Auth
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Navigate to dashboard if successful
      final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
      routerDelegate.navigateTo('/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e.code == 'user-not-found') {
        _showErrorDialog("User Not Found", "No user found with this email.");
      } else if (e.code == 'wrong-password') {
        _showErrorDialog("Incorrect Password", "The password entered is incorrect.");
      } else {
        _showErrorDialog("Sign-in Failed", e.message ?? "An error occurred.");
      }
    }
  }

  // Send password reset email
  Future<void> _forgotPassword() async {
    String email = _emailController.text.trim();

    if (!_validateEmail(email)) {
      _showErrorDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSuccessDialog("Password Reset", "A password reset link has been sent to your email.");
    } catch (e) {
      _showErrorDialog("Error", "Failed to send reset email. Please try again.");
    }
  }

  // Error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Success dialog
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isWideScreen = screenWidth > 800;

    return Scaffold(
      body: Row(
        children: [
          // Left side with image and message
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF1E7C4D),  // Green background
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/zeroWaste.jpg',  // Replace with your image
                      fit: BoxFit.cover,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Join the movement towards a sustainable future.',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: isWideScreen ? 24 : 20,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side with form
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Center(
                child: Container(
                  width: isWideScreen ? screenWidth * 0.4 : screenWidth * 0.8,
                  child: _buildLoginForm(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Login Form
  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // TrashToTreasure Heading
        Text(
          "TrashToTreasure",
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF138A36),
          ),
        ),
        SizedBox(height: 10),

        // Welcome Back message
        Text(
          "Welcome back! Please login to your account.",
          style: GoogleFonts.montserrat(fontSize: 20),
        ),
        SizedBox(height: 30),

        // Email TextField
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email",
            hintText: "example@email.com",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),

        // Password TextField
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            hintText: "Enter your password",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),

        // Forgot Password Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text(
              "Forgot your password?",
              style: GoogleFonts.montserrat(color: Color(0xFF138A36)),
            ),
          ),
        ),
        SizedBox(height: 20),

        // Sign In Button
        ElevatedButton(
          onPressed: _isLoading ? null : _signIn,  // Disable button while loading
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Sign In', style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),  // Added horizontal padding
            backgroundColor: Color(0xFF138A36),  // Green color
            foregroundColor: Colors.white,  // Ensures text color is white
            textStyle: GoogleFonts.montserrat(color: Colors.white),  // Ensures text is white
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),  // Optional: Rounded corners
            ),
          ),
        ),

        SizedBox(height: 20),

        // "Don't have an account? Sign Up" link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                final routerDelegate = Router.of(context).routerDelegate;
                if (routerDelegate is AppRouterDelegate) {
                  print('Current route before navigation: ${routerDelegate.currentPath}');
                  print('Navigating to signup page...');
                  routerDelegate.navigateTo('/signup');
                  print('Navigation requested. New route: ${routerDelegate.currentPath}');
                } else {
                  print('Router delegate not found or not of correct type');
                }
              },
              child: Text(
                "Sign Up",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Color(0xFF138A36),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
