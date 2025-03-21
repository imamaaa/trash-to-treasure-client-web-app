import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';  // For SvgPicture widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'app_router.dart';
import 'dart:typed_data';  // Import for Uint8List
import 'dart:convert';  // Import for base64 encoding/decoding


class ProfileSettingsPage extends StatefulWidget {
  final AppRouterDelegate routerDelegate;

  ProfileSettingsPage({required this.routerDelegate});

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  String cashierName = 'Cashier Name';
  String shopName = 'Shop Name';
  String currentDate = '';
  String imageUrl = ''; // Placeholder for profile image URL

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reEnterPasswordController = TextEditingController();

  bool _isProcessing = false;

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

            // Check if profileImage field exists and is not empty, otherwise use default avatar
            imageUrl = (cashierSnapshot.data() as Map<String, dynamic>)['profileImage'] ?? '';
          });
        }
      } catch (e) {
        print("Error fetching cashier info: $e");
      }
    }
  }


  // Add this to your _ProfileSettingsPageState class

  Future<void> _handleSubmit() async {
    // Validate the form fields (only password validation)
    if (passwordController.text.isNotEmpty &&
        passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (passwordController.text != reEnterPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    setState(() {
      _isProcessing = true; // Set processing state to true while saving
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Retrieve existing cashier document
      DocumentSnapshot cashierSnapshot = await FirebaseFirestore.instance
          .collection('cashiers')
          .doc(user.uid)
          .get();

      Map<String, dynamic> updates = {};

      // Update firstName only if the field is not empty
      if (firstNameController.text.isNotEmpty) {
        updates['firstName'] = firstNameController.text;
      } else {
        // Preserve previous firstName if the field is empty
        updates['firstName'] = cashierSnapshot['firstName'];
      }

      // Update lastName only if the field is not empty
      if (lastNameController.text.isNotEmpty) {
        updates['lastName'] = lastNameController.text;
      } else {
        // Preserve previous lastName if the field is empty
        updates['lastName'] = cashierSnapshot['lastName'];
      }

      // Update password only if the user has entered a new password
      if (passwordController.text.isNotEmpty &&
          passwordController.text == reEnterPasswordController.text) {
        await user.updatePassword(passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully!')),
        );
      }

      // Update Firestore with the new or preserved data
      await FirebaseFirestore.instance.collection('cashiers').doc(user.uid).update(updates);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }

    setState(() {
      _isProcessing = false; // Reset processing state after saving
    });
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

  // Get current date
  void _getCurrentDate() {
    DateTime now = DateTime.now();
    setState(() {
      currentDate = DateFormat('d MMM y').format(now); // Example: "12 Oct 2024"
    });
  }

  // Simplified Image Upload
  Future<void> _uploadProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*'; // Only allow image files
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final file = uploadInput.files!.first;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file); // Use ArrayBuffer for direct file upload

        reader.onLoadEnd.listen((e) async {
          String filePath = 'cashiers/${user.uid}/avatar.svg'; // Define file path
          Reference storageRef = FirebaseStorage.instance.ref().child(filePath);

          // Upload the file to Firebase Storage
          final fileBytes = reader.result as Uint8List; // Get file bytes
          await storageRef.putData(fileBytes);

          // Get the download URL for the image
          String downloadUrl = await storageRef.getDownloadURL();

          // Update the Firestore document with the new image URL
          await FirebaseFirestore.instance
              .collection('cashiers')
              .doc(user.uid)
              .update({'profileImage': downloadUrl});

          setState(() {
            imageUrl = downloadUrl; // Update the UI with the new image URL
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile image uploaded successfully!')),
          );
        });
      });
    } catch (e) {
      print("Error uploading profile image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cashierName, style: TextStyle(fontSize: screenWidth * 0.03, color: Color(0xFF138A36))),
            Spacer(),
            Text(shopName, style: TextStyle(fontSize: screenWidth * 0.03, color: Color(0xFF138A36))),
            Spacer(),
            Text(currentDate, style: TextStyle(fontSize: screenWidth * 0.03, color: Color(0xFF138A36))),
          ],
        ),
      ),
      drawer: buildDrawer(widget.routerDelegate),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Upload
              GestureDetector(
                onTap: _uploadProfileImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty ? Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
              SizedBox(height: 16),
              // First Name Field
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              // Last Name Field
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              // Password Field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value != null && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              // Re-enter Password Field
              TextFormField(
                controller: reEnterPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Re-enter Password'),
              ),
              SizedBox(height: 20),
              // Confirm Button
              ElevatedButton(
                onPressed: _isProcessing ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: _isProcessing
                    ? CircularProgressIndicator()
                    : Text('Confirm', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
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
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)  // Display the profile image from Firebase Storage
                              : AssetImage('assets/images/Avatar.svg') as ImageProvider,  // Default Avatar.svg
                          child: imageUrl.isEmpty
                              ? Icon(Icons.camera_alt, size: 40)  // Icon if no profile image
                              : null,  // No child if there's an image
                        ),
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

  Widget _buildNavItem(String title, String iconPath, String route, AppRouterDelegate routerDelegate,
      {VoidCallback? onTap}) {
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
