import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'app_router.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: MediaQuery.of(context).size.width, // Dynamic width
              height: MediaQuery.of(context).size.height * 0.18,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GestureDetector(
                      onTap: () {
                        final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
                        routerDelegate.navigateTo('/');
                      },
                      child: Text(
                        'TrashtoTreasure',
                        style: TextStyle(
                          color: Color.fromRGBO(30, 124, 77, 1),
                          fontSize: 35,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Get the Router's delegate
                            final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
                            routerDelegate.navigateTo('/login');

                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(19, 138, 54, 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Raleway',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                            // Get the Router's delegate
                            final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
                            // Navigate to the desired path, e.g., '/signup'
                            routerDelegate.navigateTo('/signup');
                            },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromRGBO(32, 78, 81, 1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color.fromRGBO(52, 52, 52, 1),
                              fontSize: 20,
                              fontFamily: 'Raleway',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Hero Section with Background Image, Text, and Buttons
            Container(
              width: MediaQuery.of(context).size.width, // Full width
              height: MediaQuery.of(context).size.height, // Adjust the height as needed
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Opacity(
                      opacity: 1, // Adjust the opacity for better text readability
                      child: Image.asset(
                        'assets/images/banner.jpg', // Replace with your image path
                        fit: BoxFit.cover, // Make the image cover the entire container
                      ),
                    ),
                  ),

                  // Text and Buttons Overlay
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05, // 5% horizontal padding
                        vertical: MediaQuery.of(context).size.height * 0.05, // 5% vertical padding
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start (left)
                        children: [
                          Text(
                            'Turn Trash into Treasure:',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.05, // 5% of screen width
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Join Us in Creating a Greener Future\nThrough Effortless, Smart Recycling.',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.03, // 4% of screen width
                              color: Colors.white,
                              height: 1.4,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(height: 30), // Space between text and buttons

                          Text(
                            'Waste management is a growing challenge, especially in businesses like cafes and shops where disposable items are abundant.\n'
                                'Limited recycling options and a lack of customer engagement in sustainable practices mean that recyclable waste often\nends up in landfills, missing the opportunity for a second life.',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.01, // 4% of screen width
                              color: Colors.white,
                              height: 1.7,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(height: 50), // Space between text and buttons

                          // Call to Action Buttons
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
                                  routerDelegate.navigateTo('/signup');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(19, 138, 54, 1),
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Raleway',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 30),
                              OutlinedButton(
                                onPressed: () async {
                                  // Open Google Drive link for "Learn More"
                                  const url = 'https://drive.google.com/'
                                      'file/d/1kmGazSF5fhuC_ICpDqKO5pUS4hIWLRIm/view?usp=sharing';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  side: BorderSide(color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Learn More',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Raleway',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 50),
            // OurStory Section with Image on the Right
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // Dynamic width
                height: MediaQuery.of(context).size.height * 0.9,
                child: Row(
                  children: <Widget>[
                    // Left Side Text Content
                    Expanded(
                      flex: 2, // Adjust the space for text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Where AI Drives Sustainability:\nSmarter Waste, Greener Future.',
                            style: TextStyle(
                              color: Color.fromRGBO(74, 189, 111, 1),
                              fontFamily: 'Montserrat',
                              fontSize: 64,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'TrashtoTreasure leverages AI to classify waste and incentivizes recycling through a rewards system. By transforming how institutions handle waste, we aim to promote sustainable practices and improve recycling rates within workplaces, universities, schools, and hospitals.',
                            style: TextStyle(
                              color: Color.fromRGBO(30, 30, 30, 1),
                              fontFamily: 'Raleway',
                              fontSize: 20,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                          GestureDetector(
                            onTap: () {
                                 // Get the Router's delegate
                                final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
                                // Navigate to the desired path, e.g., '/signup'
                                routerDelegate.navigateTo('/signup');

                            },
                            child: Container(
                              width: 176,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(19, 138, 54, 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Raleway',
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    SizedBox(width: 50), // Add spacing between text and image
                    // Right Side Image
                    Expanded(
                      flex: 1, // Adjust the space for the image
                      child: Container(
                        width: 550, // Adjust the width as needed
                        height: 544,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              offset: Offset(10, 10),
                              blurRadius: 20,
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage('assets/images/trashMask.jpg'), // Your image path
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

              // Our Service Section with Icons
        Padding(
          padding: EdgeInsets.all(50.0),
          child: Container(
            width: MediaQuery.of(context).size.width, // Full width of the screen
            height: MediaQuery.of(context).size.height, // Adjust height for dynamic layout
            child: Column(
              children: [
                Text(
                  'Our Service',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(74, 189, 111, 1),
                    fontFamily: 'Montserrat',
                    fontSize: 72,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'We offer innovative solutions that simplify waste management for businesses, turning sustainability into a rewarding experience for both customers and employees.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(30, 30, 30, 1),
                    fontFamily: 'Raleway',
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 30),

                // Expanded or Flexible for the Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 30.0), // Add padding
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2, // Adjust columns for smaller screens
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8, // Control the ratio of width to height of grid items
                    ),
                    itemCount: 4, // Number of service boxes
                    itemBuilder: (context, index) {
                      // Map the services to their icons dynamically
                      final services = [
                        ServiceBox(
                          title: 'AI-Powered Waste Classification',
                          svgIconPath: 'assets/images/neura.svg',
                        ),
                        ServiceBox(
                          title: 'Automatic Trash Sorting',
                          svgIconPath: 'assets/images/sortingWaste.svg',
                        ),
                        ServiceBox(
                          title: 'QR & PIN Code Verification',
                          svgIconPath: 'assets/images/qrcode.svg',
                        ),
                        ServiceBox(
                          title: 'Seamless Point System Integration',
                          svgIconPath: 'assets/images/coinshand.svg',
                        ),
                      ];
                      return services[index];
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Add Padding between Sections
            SizedBox(height: 100), // Add some vertical space before next section

      // Call to Action Section with Background Image
            Container(
              width: MediaQuery.of(context).size.width, // Dynamic width
              height: MediaQuery.of(context).size.height * 0.8, // Adjust height for more space
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/zeroWaste.jpg', // Add your image path here
                      fit: BoxFit.cover, // Make the image cover the entire container
                    ),
                  ),
                  // Semi-transparent Overlay
                  Positioned.fill(
                    child: Container(
                      color: Color.fromRGBO(0, 0, 0, 0.6), // Add a semi-transparent overlay
                    ),
                  ),
                  // Call to Action Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Turning Everyday Trash into Rewards and a Greener World',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 72,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CTAButton(
                            label: 'Learn More',
                            onPressed: () async {
                              // Open Google Drive link for "Learn More"
                              const url = 'https://drive.google.com/'
                                  'file/d/1kmGazSF5fhuC_ICpDqKO5pUS4hIWLRIm/view?usp=sharing';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          ),
                          SizedBox(width: 50),
                          CTAButton(
                            label: 'Contact Us',
                            onPressed: () async {
                              // Open mailto link for "Contact Us"
                              final Uri params = Uri(
                                scheme: 'mailto',
                                path: 'info@trashtotreasure.com',
                                query: 'subject=Contact&body=Hello Trash to Treasure Team',
                              );
                              var url = params.toString();
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 100),
            // Benefits Section
            Container(
              width: MediaQuery.of(context).size.width * 0.9, // Dynamic width
              height: MediaQuery.of(context).size.height, // Adjust height for more space
              child: Row(
                children: [
                  // Left side text content
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Benefits of Choosing Our Expertise',
                            style: TextStyle(
                              color: Color.fromRGBO(74, 189, 111, 1),
                              fontFamily: 'Montserrat',
                              fontSize: 72,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'By partnering with TrashtoTreasure, your business can seamlessly integrate sustainability into everyday operations while driving customer engagement and operational efficiency.',
                            style: TextStyle(
                              color: Color.fromRGBO(30, 30, 30, 1),
                              fontFamily: 'Raleway',
                              fontSize: 20,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                          ElevatedButton(
                            onPressed: () async {
                              // Open Google Drive link for "Learn More"
                              const url = 'https://drive.google.com/'
                                  'file/d/1kmGazSF5fhuC_ICpDqKO5pUS4hIWLRIm/view?usp=sharing';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(19, 138, 54, 1),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Learn More',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Raleway',
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Spacing between the text and the green box

                  // Right side green box with 4 benefits and SVG icons
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: MediaQuery.of(context).size.width , // Dynamic width
                      height: MediaQuery.of(context).size.height, // Adjust height for more space
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(30, 124, 77, 1), // Green box background
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Benefit 1
                          BenefitItem(
                            title: 'Seamless Integration',
                            svgPath: 'assets/images/integration.svg', // Update with your SVG path
                          ),
                          // Benefit 2
                          BenefitItem(
                            title: 'Boost Customer Loyalty',
                            svgPath: 'assets/images/loyalty.svg', // Update with your SVG path
                          ),
                          // Benefit 3
                          BenefitItem(
                            title: 'AI-Driven Efficiency',
                            svgPath: 'assets/images/aiefficiency.svg', // Update with your SVG path
                          ),
                          // Benefit 4
                          BenefitItem(
                            title: 'Promote Sustainability',
                            svgPath: 'assets/images/sprout.svg', // Update with your SVG path
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100), // Spacing between the text and the green box
            // Contact Us Section
            ContactUsSection(),
          ],
        ),
      ),
    );
  }
}

class ServiceBox extends StatelessWidget {
  final String title;
  final String svgIconPath;

  ServiceBox({required this.title, required this.svgIconPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0), // Padding inside the box
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content inside the box
        children: [
          // SVG Icon inside the box
          SvgPicture.asset(
            svgIconPath,
            width: MediaQuery.of(context).size.width * 0.1, // Adjusted to be responsive
            height: MediaQuery.of(context).size.width * 0.1, // Adjusted to be responsive
            semanticsLabel: title,
          ),
          SizedBox(height: 20), // Space between icon and title
          // Service title inside the box
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromRGBO(30, 124, 77, 1),
              fontFamily: 'Montserrat',
              fontSize: 35, // Adjusted font size for better responsiveness
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}


class CTAButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  CTAButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(19, 138, 54, 1), // Customize as needed
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'Raleway',
          color: Colors.white, // Button text color
        ),
      ),
    );
  }
}


class BenefitItem extends StatelessWidget {
  final String title;
  final String svgPath;

  BenefitItem({required this.title, required this.svgPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SVG Icon
        SvgPicture.asset(
          svgPath,
          width: 60, // Adjust icon size as needed
          height: 60,
          color: Colors.white, // Set icon color to match design
          semanticsLabel: title,
        ),
        SizedBox(height: 10),
        // Benefit Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 24,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

// Contact Us Section
class ContactUsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // Full width for responsiveness
      color: Color.fromRGBO(30, 124, 77, 1),
      padding: const EdgeInsets.all(20.0), // Add padding for better alignment
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align the text and the links/buttons
        children: [
          // Left Column: TrashtoTreasure text and description
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TrashtoTreasure text
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'TrashtoTreasure',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Description Text
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'Join the movement towards a sustainable future. Together, we can turn waste into opportunities, foster eco-conscious communities, and build a greener planet—one recycled item at a time.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Raleway',
                      fontSize: 20,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width:400),
          // Right Column with two sub-columns
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sub-column 1: Navigation links (Home, Login, Signup)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width:40),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/'); // Navigate to Home
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Raleway',
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Get the Router's delegate
                          final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
                          // Navigate to the desired path, e.g., '/signup'
                          routerDelegate.navigateTo('/login');
                          },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Raleway',
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {                                                 // Get the Router's delegate
                          final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
                          // Navigate to the desired path, e.g., '/signup'
                          routerDelegate.navigateTo('/signup');
                      },
                      child: Text(
                        'Signup',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Raleway',
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                // Sub-column 2: CTA Buttons (Learn More, Contact Us)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CTAButton(
                      label: 'Learn More',
                      onPressed: () async {
                        const url = 'https://drive.google.com/file/d'
                            '/1kmGazSF5fhuC_ICpDqKO5pUS4hIWLRIm/view?usp=sharing';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    CTAButton(
                      label: 'Contact Us',
                      onPressed: () async {
                        final Uri params = Uri(
                          scheme: 'mailto',
                          path: 'info@trashtotreasure.com',
                          query: 'subject=Contact&body=Hello Trash to Treasure Team',
                        );
                        var url = params.toString();
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




