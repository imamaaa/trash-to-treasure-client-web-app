import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart'; // Correct package
import 'package:overlay_support/overlay_support.dart';
import 'package:intl/intl.dart'; // For formatting date
import 'app_router.dart';
import 'profile_avatar.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isScanning = true;
  String cashierName = 'Cashier Name';  // Placeholder for Cashier's name
  String shopName = 'Shop Name';        // Placeholder for Shop name
  String currentDate = '';              // Placeholder for Current date

  @override
  void initState() {
    super.initState();
    _fetchCashierInfo();
    _fetchShopInfo();
    _getCurrentDate();  // Fetch the current date
  }

  Future<void> _fetchCashierInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot cashierSnapshot = await FirebaseFirestore.instance
            .collection('cashiers')
            .doc(user.uid)
            .get();
        if (cashierSnapshot.exists) {
          setState(() {
            cashierName = "${cashierSnapshot['firstName']} ${cashierSnapshot['lastName']}";
          });
        }
      } catch (e) {
        print("Error fetching cashier info: $e");
      }
    }
  }

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

  // Get current date and format it
  void _getCurrentDate() {
    DateTime now = DateTime.now();
    setState(() {
      currentDate = DateFormat('d MMM y').format(now);  // Example: "12 Oct 2024"
    });
  }

  Future<void> _handleQRCode(String scanData) async {
    setState(() {
      _isScanning = false; // Disable scanning while processing
    });

    try {
      final trashItemID = scanData;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in!')),
        );
        return;
      }

      DocumentSnapshot trashItemDoc = await FirebaseFirestore.instance.collection('trashItems').doc(trashItemID).get();
      if (!trashItemDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid QR Code!')),
        );
        return;
      }

      final trashData = trashItemDoc.data() as Map<String, dynamic>;
      final userID = trashData['userID'];
      final pointsAssigned = trashData['pointsAssigned'];

      if (trashData['status'] != 'active') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: QR Code is not active!')),
        );
        return;
      }

      // Update trash item status
      await FirebaseFirestore.instance.collection('trashItems').doc(trashItemID).update({
        'status': 'redeemed',
      });

      await _updateUserWallet(userID, pointsAssigned);
      await _updateUserHistory(userID, trashItemID);
      await _updateShopHistory(trashItemID);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code redeemed successfully!')),
      );

      setState(() {
        _isScanning = true; // Re-enable scanning after success
      });
    } catch (e) {
      print("Error processing QR code: $e");
    }
  }

  Future<void> _updateUserWallet(String userID, int pointsAssigned) async {
    DocumentSnapshot userWalletDoc = await FirebaseFirestore.instance.collection('userWallets').doc(userID).get();
    if (!userWalletDoc.exists) return;

    final userWallet = userWalletDoc.data() as Map<String, dynamic>;
    final currentPoints = userWallet['currentPoints'];
    final updatedPoints = currentPoints - pointsAssigned;

    await FirebaseFirestore.instance.collection('userWallets').doc(userID).update({
      'currentPoints': updatedPoints,
    });

    // Send a notification to the user
    _sendTopNotification(
      'Points Redeemed for Customer',
      'Customer new balance is $updatedPoints points.',
      'https://firebasestorage.googleapis.com/v0/b/trashtotreasure-4a540.appspot.com/o/featureIcons%2Fwallet.svg?alt=media&token=678c0d5a-b1e1-40fc-a23c-4af4f854a7a6'
    );
  }

  Future<void> _updateUserHistory(String userID, String trashItemID) async {
    try {
      DocumentSnapshot userHistoryDoc = await FirebaseFirestore.instance.collection('userHistory').doc(userID).get();
      if (!userHistoryDoc.exists) return;

      final userHistory = userHistoryDoc.data() as Map<String, dynamic>;
      List<String> activeItems = List<String>.from(userHistory['active']);
      List<String> redeemedItems = List<String>.from(userHistory['redeemed']);

      if (activeItems.contains(trashItemID)) {
        activeItems.remove(trashItemID);  // Remove from active
        redeemedItems.add(trashItemID);   // Add to redeemed

        await FirebaseFirestore.instance.collection('userHistory').doc(userID).update({
          'active': activeItems,
          'redeemed': redeemedItems,
        });

        // Send notification to the user
        _sendTopNotification(
          'History Updated for Customer',
          'Customer history has been updated with the redeemed item.',
          'https://firebasestorage.googleapis.com/v0/b/trashtotreasure-4a540.appspot.com/o/featureIcons%2Freceipt.svg?alt=media&token=f3abdf67-f6f8-4275-be97-71678f3a226f'
        );
      }
    } catch (e) {
      print("Error updating user history: $e");
    }
  }


  Future<void> _updateShopHistory(String trashItemID) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Fetch the shop where the current user is the owner
      final shopSnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      if (shopSnapshot.docs.isNotEmpty) {
        final shopID = shopSnapshot.docs.first.id;  // Fetch the shop's document ID
        final shopHistoryDoc = await FirebaseFirestore.instance.collection('shopHistory').doc(shopID).get();
        final timestamp = DateTime.now().toIso8601String();  // Current timestamp

        if (!shopHistoryDoc.exists) {
          // Create a new document for the shop if it doesn't exist
          await FirebaseFirestore.instance.collection('shopHistory').doc(shopID).set({
            'history': [
              {
                'cashierID': user.uid,
                'trashItemID': trashItemID,
                'timestamp': timestamp,
              }
            ],
          });
          print('New shop history document created for shopID: $shopID');
        } else {
          // Update existing document by appending to the history array
          final shopHistory = shopHistoryDoc.data() as Map<String, dynamic>;
          List<dynamic> history = shopHistory['history'] ?? [];
          history.add({
            'cashierID': user.uid,
            'trashItemID': trashItemID,
            'timestamp': timestamp,
          });

          await FirebaseFirestore.instance.collection('shopHistory').doc(shopID).update({
            'history': history,
          });
          print('Shop history updated for shopID: $shopID');
        }
      } else {
        print('No matching shop found for userID: ${user.uid}');
      }
    } catch (e) {
      print("Error updating shop history: $e");
    }
  }


  void _sendTopNotification(String title, String message, String iconPath) {
    showSimpleNotification(
      Row(
        children: [
          SvgPicture.asset(iconPath, height: 40, width: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      background: const Color(0xFF989898),
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppRouterDelegate routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48),
            Text(
              cashierName,  // Display Cashier's name
              style: TextStyle(fontSize: 25, color: Color(0xFF138A36)),
            ),
            Spacer(),
            Text(
              shopName,  // Display Shop name
              style: TextStyle(fontSize: 25, color: Color(0xFF138A36)),
            ),
            Spacer(),
            Text(
              currentDate,  // Display Current date
              style: TextStyle(fontSize: 25, color: Color(0xFF138A36)),
            ),
          ],
        ),
      ),
      drawer: buildDrawer(routerDelegate),
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 5,
              child: FlutterWebQrcodeScanner(
                width: MediaQuery.of(context).size.width * 0.8,  // 80% of screen width
                height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
                cameraDirection: CameraDirection.back,  // Default to back camera
                stopOnFirstResult: true,  // Stop scanning after first successful result
                onGetResult: (String result) async {
                  if (_isScanning) {
                    setState(() {
                      _isScanning = false;  // Prevent further scans
                    });

                    if (result.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('QR Code scanned successfully!')),
                      );

                      await _handleQRCode(result);  // Handle the QR code data
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: Scanning failed, QR Code is empty.')),
                      );
                      setState(() {
                        _isScanning = true;  // Re-enable scanning after error
                      });
                    }
                  }
                },
              )
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,  // Green background
                foregroundColor: Colors.white,   // White text
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              onPressed: () {
                routerDelegate.navigateTo('/history');
              },
              child: Text('History'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDrawer(AppRouterDelegate routerDelegate) {
    return Drawer(
      child: Container(
        color: const Color(0xFF138A36),
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF138A36)),
              child: Text(
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
                children: [
                  _buildNavItem(
                    'Dashboard',
                    'assets/images/mainPage.svg',
                    '/dashboard',
                    routerDelegate,
                  ),
                  _buildNavItem(
                    'Scan QR Code',
                    'assets/images/dashQR.svg',
                    '/scan_qr',
                    routerDelegate,
                  ),
                  _buildNavItem(
                    'Enter PIN Code',
                    'assets/images/DialPad.svg',
                    '/enter_pin',
                    routerDelegate,
                  ),
                  _buildNavItem(
                    'History',
                    'assets/images/Bill.svg',
                    '/history',
                    routerDelegate,
                  ),
                  _buildNavItem(
                    cashierName,
                    'assets/images/usercircle.svg',
                    '/profile_settings',
                    routerDelegate,
                  ),
                 // Divider for Logout
                  const SizedBox(height: 30),
                  Divider(color: Colors.white54),
                  _buildNavItem(
                    'Logout',
                    'assets/images/logout.svg',
                    '/logout',
                    routerDelegate,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      routerDelegate.navigateTo('/login'); // Navigate to login page after sign-out
                    },
                  ),
               //Profile and View Profile section
                  Divider(color: Colors.white54),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                      ProfileAvatar(
                      radius: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cashierName, // Display cashier name
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
          ],
        ),
      ),
    );
  }

// Modified _buildNavItem to include optional onTap functionality
  Widget _buildNavItem(
      String title, String iconPath, String route, AppRouterDelegate routerDelegate,
      {VoidCallback? onTap}) {
    final String currentPath = routerDelegate.currentPath;

    return Container(
      decoration: BoxDecoration(
        color: currentPath == route ? Color(0xFF4ABD6F) : Color(0xFF138A36), // Use different green if selected
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
          style: const TextStyle(color: Colors.white),
        ),
        onTap: onTap ??
                () {
              if (currentPath != route) {
                routerDelegate.navigateTo(route); // Navigate using AppRouterDelegate
              }
            },
      ),
    );
  }

}
