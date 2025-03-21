import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:intl/intl.dart';
import 'app_router.dart';
import 'profile_avatar.dart';

class EnterPinPage extends StatefulWidget {
  @override
  _EnterPinPageState createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  List<String> pin = List<String>.filled(6, ''); // Stores the entered PIN
  String cashierName = 'Cashier Name';  // Placeholder for Cashier's name
  String shopName = 'Shop Name';        // Placeholder for Shop name
  String currentDate = '';              // Placeholder for Current date
  bool _isProcessing = false;           // To disable UI while processing

  @override
  void initState() {
    super.initState();
    _fetchCashierInfo();
    _fetchShopInfo();
    _getCurrentDate();
  }

  // Fetch cashier info from Firestore
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

  // Fetch shop info from Firestore
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

  // Get current date
  void _getCurrentDate() {
    DateTime now = DateTime.now();
    setState(() {
      currentDate = DateFormat('d MMM y').format(now);  // Example: "12 Oct 2024"
    });
  }

// Handle PIN Code verification and processing
  // Handle PIN Code verification and processing
Future<void> _handlePinCode(String pinCode) async {
  setState(() {
    _isProcessing = true; // Disable UI while processing
  });

  try {
    // Ensure that the entered PIN is treated as an integer
    final enteredPin = int.tryParse(pinCode);

    if (enteredPin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PIN: Please enter a valid number.')),
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    // Print entered PIN for debugging
    print("Entered PIN: $enteredPin");

    // Search for the trashItem with this PIN code (as an integer)
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('trashItems')
        .where('pinCode', isEqualTo: enteredPin) // Query using the integer pinCode
        .get();

    // Check if the query result is empty
    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid PIN Code!')),
      );
      setState(() {
        _isProcessing = false;
      });

      // Debugging: Log if no results were found
      print("No matching PIN found in Firestore.");
      return;
    }

    // Log the retrieved data
    print("Matching PIN found in Firestore: ${query.docs.first.data()}");

    // If PIN is found, handle the rest of the logic
    DocumentSnapshot trashItemDoc = query.docs.first;
    final trashData = trashItemDoc.data() as Map<String, dynamic>;
    final trashItemID = trashItemDoc.id;
    final userID = trashData['userID'];
    final pointsAssigned = trashData['pointsAssigned'];

    // Ensure the status is active
    if (trashData['status'] != 'active') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: PIN Code is not active!')),
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    // Process trashItem (redeem)
    await FirebaseFirestore.instance.collection('trashItems').doc(trashItemID).update({
      'status': 'redeemed',
    });

    // Update user's wallet and history
    await _updateUserWallet(userID, pointsAssigned);
    await _updateUserHistory(userID, trashItemID);
    await _updateShopHistory(trashItemID);

    // Show success message
    _showSuccessMessage('PIN Code verified and redeemed successfully!');
  } catch (e) {
    print("Error processing PIN code: $e");

    // Show error message to the cashier
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),  // You can customize this message
    );
  }

  setState(() {
    _isProcessing = false; // Re-enable UI
  });
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

  // Use the same logic as in scan_qr.dart for updating the shop history
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
        }
      }
    } catch (e) {
      print("Error updating shop history: $e");
    }
  }

  // Success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3), // Show for 3 seconds
        backgroundColor: Colors.green,
      ),
    );
  }

  // Notification widget
  void _sendTopNotification(String title, String message, String iconPath) {
    showSimpleNotification(
      Row(
        children: [
          SvgPicture.network(iconPath, height: 40, width: 40),
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

  // Build PIN Entry Widget
  Widget buildPinEntry(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: boxWidth,
          height: boxWidth,
          child: TextField(
            onChanged: (value) {
              if (value.length == 1) {
                pin[index] = value;
                if (index < 5) {
                  FocusScope.of(context).nextFocus(); // Move to next box
                }
              }
              if (value.isEmpty && index > 0) {
                pin[index] = ''; // Clear pin box
                FocusScope.of(context).previousFocus(); // Go back to the previous box
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              counterText: '',
            ),
            maxLength: 1,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }

  // Drawer navigation items
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
                  // Profile and View Profile section
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

  // Build nav item with route navigation
  Widget _buildNavItem(
      String title, String iconPath, String route, AppRouterDelegate routerDelegate,
      {VoidCallback? onTap}) {
    final String currentPath = routerDelegate.currentPath;

    return Container(
      decoration: BoxDecoration(
        color: currentPath == route ? Color(0xFF4ABD6F) : Color(0xFF138A36), // Highlight selected item
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

  @override
  Widget build(BuildContext context) {
    final AppRouterDelegate routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cashierName, style: TextStyle(fontSize: 25, color: Color(0xFF138A36))),
            Spacer(),
            Text(shopName, style: TextStyle(fontSize: 25, color: Color(0xFF138A36))),
            Spacer(),
            Text(currentDate, style: TextStyle(fontSize: 25, color: Color(0xFF138A36))),
          ],
        ),
      ),
      drawer: buildDrawer(routerDelegate),
      body: Column(
        children: [
          Spacer(flex: 1),
          buildPinEntry(context),
          Spacer(flex: 1),ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  ),
  onPressed: _isProcessing
      ? null
      : () {
          String enteredPin = pin.join();  // Combine all digits
          if (enteredPin.length == 6) {
            _handlePinCode(enteredPin); // Process PIN code
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a 6-digit PIN.')),
            );
          }
      },
  child: _isProcessing
      ? CircularProgressIndicator()
      : Text('Verify PIN'),
),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
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
}
