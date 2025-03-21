import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'app_router.dart';
import 'profile_avatar.dart';

class ShopHistoryPage extends StatefulWidget {
  final AppRouterDelegate routerDelegate;

  ShopHistoryPage({required this.routerDelegate});
  @override
  _ShopHistoryPageState createState() => _ShopHistoryPageState();
}

class _ShopHistoryPageState extends State<ShopHistoryPage> {
  String cashierName = 'Cashier Name';  // Placeholder for Cashier's name
  String shopName = 'Shop Name';        // Placeholder for Shop name
  String currentDate = '';              // Placeholder for Current date
  bool _isLoading = true;               // Track loading state
  List historyData = [];                // Store fetched history

  @override
  void initState() {
    super.initState();
    _fetchCashierInfo();
    _fetchShopInfo();
    _getCurrentDate();
    _fetchShopHistory();
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
        if (cashierSnapshot.exists && mounted) {
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
        if (shopSnapshot.docs.isNotEmpty && mounted) {
          setState(() {
            shopName = shopSnapshot.docs.first['name'];
          });
        }
      } catch (e) {
        print("Error fetching shop info: $e");
      }
    }
  }

  // Fetch shop history from Firestore
  Future<void> _fetchShopHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot shopSnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      if (shopSnapshot.docs.isNotEmpty) {
        final shopID = shopSnapshot.docs.first.id;
        DocumentSnapshot shopHistoryDoc = await FirebaseFirestore.instance
            .collection('shopHistory')
            .doc(shopID)
            .get();

        if (shopHistoryDoc.exists && mounted) {
          List<dynamic> history = shopHistoryDoc['history'];
          setState(() {
            historyData = history.reversed.toList(); // Display in reverse chronological order
          });
        }
      }
    } catch (e) {
      print("Error fetching shop history: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Loading completed
        });
      }
    }
  }

  // Get current date
  void _getCurrentDate() {
    DateTime now = DateTime.now();
    if (mounted) {
      setState(() {
        currentDate = DateFormat('d MMM y').format(now);  // Example: "12 Oct 2024"
      });
    }
  }

  // Fetch trash item details and show them in a popup dialog
  Future<void> _showTrashItemDetails(BuildContext context, String trashItemID) async {
    try {
      DocumentSnapshot trashItemDoc = await FirebaseFirestore.instance
          .collection('trashItems')
          .doc(trashItemID)
          .get();

      if (trashItemDoc.exists) {
        final trashData = trashItemDoc.data() as Map<String, dynamic>;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Trash Item Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trash Item ID: $trashItemID'),
                  Text('Points Assigned: ${trashData['pointsAssigned']}'),
                  Text('Type: ${trashData['type']}'),
                  Text('Number of Items: ${trashData['numOfItems']}'),
                  Text('Timestamp: ${(trashData['timestamp'] as Timestamp).toDate()}'),
                  Text('Status: ${trashData['status']}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error fetching trash item details: $e");
    }
  }

  // Build history tiles based on the data
  Widget _buildHistoryTile(BuildContext context, Map<String, dynamic> historyItem) {
    final String cashierID = historyItem['cashierID'];
    final String trashItemID = historyItem['trashItemID'];
    final DateTime timestamp = DateTime.parse(historyItem['timestamp']);

    return ListTile(
      title: Text('Trash Item ID: $trashItemID'),
      subtitle: Text('Redeemed on: ${DateFormat('d MMM y – kk:mm').format(timestamp)}'),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        _showTrashItemDetails(context, trashItemID);
      },
    );
  }

  // Responsive sizing method
  double _responsiveSize(BuildContext context, double size) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * size;
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
      drawer: buildDrawer(widget.routerDelegate),  // <-- Here we use widget.routerDelegate
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner while data is being fetched
          : ListView.builder(
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          return _buildHistoryTile(context, historyData[index]);
        },
      ),
    );
  }

  // Navigation Drawer
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
                  _buildNavItem('Dashboard', 'assets/images/mainPage.svg', '/dashboard', routerDelegate),
                  _buildNavItem('Scan QR Code', 'assets/images/dashQR.svg', '/scan_qr', routerDelegate),
                  _buildNavItem('Enter PIN Code', 'assets/images/DialPad.svg', '/enter_pin', routerDelegate),
                  _buildNavItem('History', 'assets/images/Bill.svg', '/history', routerDelegate),
                  _buildNavItem(cashierName, 'assets/images/usercircle.svg', '/profile_settings', routerDelegate),
                const SizedBox(height: 30),
                  Divider(color: Colors.white54),
                  _buildNavItem(
                    'Logout',
                    'assets/images/logout.svg',
                    '/logout',
                    routerDelegate,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      routerDelegate.navigateTo('/login');
                    },
                  ),
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

  // Navigation Item Builder
  Widget _buildNavItem(String title, String iconPath, String route, AppRouterDelegate routerDelegate, {VoidCallback? onTap}) {
    final String currentPath = routerDelegate.currentPath;

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
          style: const TextStyle(color: Colors.white),
        ),
        onTap: onTap ?? () {
          if (currentPath != route) {
            routerDelegate.navigateTo(route);
          }
        },
      ),
    );
  }
}
