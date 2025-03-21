import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth for email verification
import 'dart:async';  // For using Timer
import 'opt_success.dart';  // Assuming you have OTPSuccessPage defined

class OTPFailPage extends StatefulWidget {
  @override
  _OTPFailPageState createState() => _OTPFailPageState();
}

class _OTPFailPageState extends State<OTPFailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;  // Initialize FirebaseAuth
  Timer? _timer;
  int _attempts = 0;

  // Function to resend the email verification
  Future<void> _resendVerificationEmail(BuildContext context) async {
    try {
      User? user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        // Send the email verification
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent again to ${user.email}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User is already verified or not available')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend verification email: $e')),
      );
    }
  }

  // Function to check email verification status periodically
  void _startVerificationCheck() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      _attempts++;
      if (_attempts >= 10) {  // Stop checking after 30 seconds (10 attempts)
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification attempt timed out')),
        );
      } else {
        User? user = _auth.currentUser;
        await user?.reload();  // Reload the user to get updated status
        if (user != null && user.emailVerified) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OTPSuccessPage()),  // Navigate to success page
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();  // Cancel timer when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to verify email.',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Resend the verification email and start checking for verification status
                _resendVerificationEmail(context);
                _startVerificationCheck();  // Start checking email verification status
              },
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
