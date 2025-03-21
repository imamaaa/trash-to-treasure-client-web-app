import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';  // Import for TapGestureRecognizer
import 'package:email_validator/email_validator.dart';
import 'email_verification_page.dart';
import 'login.dart';
import 'landingPage.dart';
import 'app_router.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // Validate email format
    if (!EmailValidator.validate(email)) {
      _showErrorDialog(context, "Invalid Email", "Please enter a valid email address.");
      return;
    }

    // Validate password length
    if (password.length < 6) {
      _showErrorDialog(context, "Password Error", "Password must be at least 6 characters.");
      return;
    }

    // Validate password match
    if (password != confirmPassword) {
      _showErrorDialog(context, "Password Error", "Passwords do not match.");
      return;
    }

    try {
      // Create user with Firebase Authentication (but not yet in Firestore)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Show message for email verification and navigate to verification page
      final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
      routerDelegate.navigateTo('/email_verification', params: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      });


    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, "Registration Error", e.message ?? "Failed to register.");
    }
  }


  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 800;  // Adjust based on screen size for web

    return Scaffold(
      body: Row(
        children: [
          // Left side with green background and image
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF1E7C4D),  // Green background
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/zeroWaste.jpg',  // Replace with your image in assets/images folder
                      fit: BoxFit.cover,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Join the movement towards a sustainable future.',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side with form
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                width: isWideScreen ? screenWidth * 0.4 : screenWidth * 0.8,  // Adjust width based on screen size
                padding: EdgeInsets.all(16),
                child: ListView(
                  children: [
                    // System Name and Welcome Message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LandingPage()),  // Link to LandingPage
                            );
                          },
                          child: Text(
                            'TrashToTreasure',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Color(0xFF1E7C4D),  // Same green color as background
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Welcome Aboard!',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Please create a new account.',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Form fields with margin adjusted dynamically
                    Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.0246),
                      child: TextField(
                        controller: _firstNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: "First Name",
                          hintText: "Enter your first name",
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.0246),
                      child: TextField(
                        controller: _lastNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          hintText: "Enter your last name",
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.0246),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          hintText: "e.g., example@example.com",
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.0246),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter your password",
                          helperText: "Password should be at least 6 characters in length",
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.0246),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Re-enter Password",
                          hintText: "Confirm your password",
                          helperText: "Both passwords should match",
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _signUp,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E7C4D),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // Already have an account? Sign In
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.black,  // Black color for the first part
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Color(0xFF1E7C4D),  // Green color for the "Sign In" part
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
                                  routerDelegate.navigateTo('/login');

                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
