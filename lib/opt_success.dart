import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shop_details.dart';
import 'app_router.dart';

class OTPSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isWideScreen = screenWidth > 800;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.064,
            screenHeight * 0.14,
            screenWidth * 0.064,
            screenHeight * 0.035,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.04),
                child: SizedBox(
                  width: isWideScreen ? screenWidth * 0.4 : screenWidth * 0.7,
                  height: isWideScreen ? screenHeight * 0.3 : screenHeight * 0.25,
                  child: SvgPicture.asset(
                    'assets/images/verified_person.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                child: Text(
                  'Account Verified!',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: isWideScreen ? screenWidth * 0.03 : screenWidth * 0.045,
                    height: 1.5,
                    color: Color(0xFF138A36),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                child: Text(
                  'You have successfully created an account.\nPress "Ok" to link your account with a shop.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: isWideScreen ? screenWidth * 0.025 : screenWidth * 0.035,
                    height: 1.5,
                    color: Color(0xFF343434),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              GestureDetector(
                onTap: () {
                  final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
                  routerDelegate.navigateTo('/shop_details');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF138A36),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.12,
                  ),
                  child: Text(
                    'Ok',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: isWideScreen ? screenWidth * 0.03 : screenWidth * 0.04,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
