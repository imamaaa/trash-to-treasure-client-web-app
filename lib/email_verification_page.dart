import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'opt_success.dart';
import 'otp_fail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'dart:async';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;

  EmailVerificationPage({required this.email, required this.firstName, required this.lastName});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? timer;
  int attempts = 0; // To limit the number of checks

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      attempts++;
      if (attempts >= 10) { // After 30 seconds, if no verification, fail it
        timer.cancel();
        final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
        routerDelegate.navigateTo('/otp_fail');  // Assuming you create this route in the delegate
      } else {
        checkEmailVerified(); // Check if email is verified
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // This method will check if the email has been verified and save the cashier data to Firestore
  Future<void> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      timer?.cancel();

      // Write cashier data to Firestore after email verification
      await FirebaseFirestore.instance.collection('cashiers').doc(user.uid).set({
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'email': widget.email,
      });

      // Navigate to OTP success page
      final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
      routerDelegate.navigateTo('/opt_success');  // Assuming you create this route in the delegate

    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isWideScreen = screenWidth > 800;

    return Scaffold(
      body: Center(
        child: Container(
          width: isWideScreen ? screenWidth * 0.5 : screenWidth * 0.85, // Adjust for wider screens
          height: screenHeight * 0.8, // Take up 80% of the screen height
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // 5% horizontal padding
            vertical: screenHeight * 0.05, // 5% vertical padding
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x17000000),
                offset: Offset(0, 8),
                blurRadius: 49,
              ),
            ],
            borderRadius: BorderRadius.circular(20), // Added rounded corners for a modern look
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Expanded or Flexible to handle SVG scaling dynamically
              Flexible(
                child: SvgPicture.asset(
                  'assets/images/OTP.svg',
                  width: screenWidth * (isWideScreen ? 0.3 : 0.6), // Dynamically adjust the width based on screen size
                  height: screenHeight * 0.3, // Height also adjusted for responsiveness
                  fit: BoxFit.contain, // Ensures the SVG scales appropriately
                ),
              ),
              SizedBox(height: screenHeight * 0.05), // Dynamic spacing
              Text(
                "Please check your email and click on the verification link to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: isWideScreen ? 20 : 16, // Adjust text size based on screen
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
