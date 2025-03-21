import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore
import 'package:intl/intl.dart';
import 'app_router.dart';
import 'profile_avatar.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String cashierName = 'Cashier Name';  // Placeholder for Cashier's name
  String shopName = 'Dashboard';        // Placeholder for Shop name
  String currentDate = '';              // Placeholder for current date

  @override
  void initState() {
    super.initState();
    _fetchCashierInfo();
    _fetchShopInfo();
    _getCurrentDate();
  }

  Future<void> _fetchCashierInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot cashierSnapshot = await FirebaseFirestore.instance
            .collection('cashiers')
            .doc(user.uid)
            .get();
        if (cashierSnapshot.exists && mounted) {
          setState(() {
            cashierName = "${cashierSnapshot['firstName']} ${cashierSnapshot['lastName']}";
          });
        }
      } catch (e) {
        if (mounted) {
          print("Error fetching cashier info: $e");
        }
      }
    }
  }

  // Fetch shop name from Firestore where ownerID == logged-in user's ID
  Future<void> _fetchShopInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot shopSnapshot = await FirebaseFirestore.instance
            .collection('shops')
            .where('ownerId', isEqualTo: user.uid)
            .get();
        if (shopSnapshot.docs.isNotEmpty) {
          setState(() {
            shopName = shopSnapshot.docs.first['name'];
          });
        }
      } catch (e) {
        print("Error fetching shop info: $e");
      }
    }
  }

  // Get current date and format it correctly
  void _getCurrentDate() {
    DateTime now = DateTime.now();
    setState(() {
      currentDate = DateFormat('d MMM y').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Get the current route path from AppRouterDelegate
    final AppRouterDelegate routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
    final String currentPath = routerDelegate.currentPath;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48),
            Text(
              cashierName, // Display Cashier's name
              style: TextStyle(fontSize: 25, color: Color(0xFF138A36)),
            ),
            Spacer(),
            Text(
              shopName, // Display Shop name
              style: TextStyle(fontSize: 25, color: Color(0xFF138A36)),
            ),
            Spacer(),
            Text(
              currentDate, // Display Current date
              style: TextStyle(fontSize: 25, color: Color(0xFF138A36)),
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(currentPath, routerDelegate),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height, // Full height
          alignment: Alignment.center, // Center the content vertically and horizontally
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              _buildGreenRoundedButton(
                context,
                'Scan QR Code',
                Icons.qr_code_scanner,
                '/scan_qr',
              ),
              SizedBox(height: 24), // Add space between the two buttons
              _buildGreenRoundedButton(
                context,
                'Enter PIN Code',
                Icons.lock,
                '/enter_pin',
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDrawer(String currentPath, AppRouterDelegate routerDelegate) {
    return Drawer(
      child: Container(
        color: Color(0xFF138A36),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF138A36)),
              child: const Text(
                'TrashtoTreasure',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    'Dashboard',
                    'assets/images/mainPage.svg',
                    '/dashboard',
                    currentPath,
                    routerDelegate,
                  ),
                  _buildDrawerItem(
                    'Scan QR Code',
                    'assets/images/dashQR.svg',
                    '/scan_qr',
                    currentPath,
                    routerDelegate,
                  ),
                  _buildDrawerItem(
                    'Enter PIN Code',
                    'assets/images/DialPad.svg',
                    '/enter_pin',
                    currentPath,
                    routerDelegate,
                  ),
                  _buildDrawerItem(
                    'History',
                    'assets/images/Bill.svg',
                    '/history',
                    currentPath,
                    routerDelegate,
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      'assets/images/usercircle.svg',
                      color: Colors.white,
                      width: 24,
                      height: 24,
                    ),
                    title: Text(cashierName, style: TextStyle(color: Colors.white)),
                    onTap: () {
                      routerDelegate.navigateTo('/profile_settings');
                    },
                  ),
                  const SizedBox(height: 30),
                  Divider(color: Colors.white54),
                  _buildDrawerItem(
                    'Logout',
                    'assets/images/logout.svg',
                    '/logout',
                    currentPath,
                    routerDelegate,
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white54),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ProfileAvatar(radius: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cashierName,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () {
                            routerDelegate.navigateTo('/profile_settings');
                          },
                          child: const Text(
                            'View Profile',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, String iconPath, String route, String currentPath, AppRouterDelegate routerDelegate) {
    return Container(
      decoration: BoxDecoration(
        color: currentPath == route ? Color(0xFF4ABD6F) : Color(0xFF138A36),
        border: currentPath == route ? Border.all(color: Colors.white, width: 2.0) : null,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          iconPath,
          color: Colors.white,
          width: 24,
          height: 24,
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        onTap: () {
          if (currentPath != route) {
            routerDelegate.navigateTo(route);
          }
        },
      ),
    );
  }

  Widget _buildGreenRoundedButton(
      BuildContext context, String title, IconData icon, String routeName) {
    return ElevatedButton.icon(
      onPressed: () {
        final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
        routerDelegate.navigateTo(routeName); // Navigate using RouterDelegate
      },
      icon: Icon(icon, size: 40),  // Make the icon bigger
      label: Text(
        title,
        style: TextStyle(fontSize: 24),  // Increase text size
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF138A36), // Green color
        foregroundColor: Colors.white, // Sets text and icon color to white
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60), // Increase padding for larger buttons
      ),
    );
  }

}
