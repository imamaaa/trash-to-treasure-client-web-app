import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import 'app_router.dart';

class ShopDetailsPage extends StatefulWidget {
  @override
  _ShopDetailsPageState createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {

  String? selectedProvince; // Store the selected province
  final List<String> provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad'
  ]; // List of provinces
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Toggles for the days of the week
  bool isOpenMonday = false;
  bool isOpenTuesday = false;
  bool isOpenWednesday = false;
  bool isOpenThursday = false;
  bool isOpenFriday = false;
  bool isOpenSaturday = false;
  bool isOpenSunday = false;

  // Time pickers for each day
  TimeOfDay openingTimeMonday = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closingTimeMonday = TimeOfDay(hour: 17, minute: 0);
  TimeOfDay openingTimeTuesday = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closingTimeTuesday = TimeOfDay(hour: 17, minute: 0);
  TimeOfDay openingTimeWednesday = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closingTimeWednesday = TimeOfDay(hour: 17, minute: 0);
  TimeOfDay openingTimeThursday = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closingTimeThursday = TimeOfDay(hour: 17, minute: 0);
  TimeOfDay openingTimeFriday = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closingTimeFriday = TimeOfDay(hour: 17, minute: 0);
  TimeOfDay openingTimeSaturday = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closingTimeSaturday = TimeOfDay(hour: 17, minute: 0);
  TimeOfDay openingTimeSunday = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closingTimeSunday = TimeOfDay(hour: 17, minute: 0);

  Future<void> _selectTime(BuildContext context, bool isOpening,
      Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening
          ? TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: 17, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1E7C4D), // Green color for the time picker
              onPrimary: Colors.white, // White font color
              surface: Color(0xFF1E7C4D),
              onSurface: Colors.white, // White for the text
            ),
            dialogBackgroundColor: Colors.black, // Background color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        onTimeSelected(picked);
      });
    }
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _validatePhone(String phone) {
    return RegExp(r'^\+92\s\d{3}\s\d{7}$').hasMatch(phone);
  }

  bool isFormValid() {
    return _shopNameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        selectedProvince != null &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
  }

  Future<void> _registerNewShop() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showErrorDialog("User Error", "Unable to find the authenticated user.");
      return;
    }

    String shopName = _shopNameController.text.trim();
    String address = _addressController.text.trim();
    String city = _cityController.text.trim();
    String state = selectedProvince ?? '';
    String zip = _zipController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();

    if (shopName.isEmpty) {
      _showErrorDialog("Incomplete Details", "Shop Name is required.");
      return;
    }

    if (address.isEmpty) {
      _showErrorDialog("Incomplete Details", "Address is required.");
      return;
    }

    if (city.isEmpty) {
      _showErrorDialog("Incomplete Details", "City is required.");
      return;
    }

    if (selectedProvince == null) {
      _showErrorDialog("Incomplete Details", "Please select a province.");
      return;
    }

    if (phone.isEmpty) {
      _showErrorDialog("Incomplete Details", "Phone Number is required.");
      return;
    }

    if (email.isEmpty) {
      _showErrorDialog("Incomplete Details", "Email Address is required.");
      return;
    }

    if (!_validateEmail(email)) {
      _showErrorDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    if (!_validatePhone(phone)) {
      _showErrorDialog("Invalid Phone", "Please enter a valid phone number.");
      return;
    }

    if (!isFormValid()) {
      _showErrorDialog(
          "Incomplete Details", "Please fill in all the required fields.");
      return;
    }

    if (isOpenMonday && (openingTimeMonday == null || closingTimeMonday == null)) {
      _showErrorDialog(
          "Time Error", "Please select opening and closing times for Monday.");
      return;
    }

    if (isOpenTuesday &&
        (openingTimeTuesday == null || closingTimeTuesday == null)) {
      _showErrorDialog(
          "Time Error", "Please select opening and closing times for Tuesday.");
      return;
    }

    DocumentReference shopRef = FirebaseFirestore.instance.collection('shops').doc();

    await shopRef.set({
      'name': shopName,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'phone': phone,
      'email': email,
      'operatingHours': {
        'Monday': isOpenMonday
            ? '${openingTimeMonday.format(context)} - ${closingTimeMonday.format(context)}'
            : 'Closed',
        'Tuesday': isOpenTuesday
            ? '${openingTimeTuesday.format(context)} - ${closingTimeTuesday.format(context)}'
            : 'Closed',
        'Wednesday': isOpenWednesday
            ? '${openingTimeWednesday.format(context)} - ${closingTimeWednesday.format(context)}'
            : 'Closed',
        'Thursday': isOpenThursday
            ? '${openingTimeThursday.format(context)} - ${closingTimeThursday.format(context)}'
            : 'Closed',
        'Friday': isOpenFriday
            ? '${openingTimeFriday.format(context)} - ${closingTimeFriday.format(context)}'
            : 'Closed',
        'Saturday': isOpenSaturday
            ? '${openingTimeSaturday.format(context)} - ${closingTimeSaturday.format(context)}'
            : 'Closed',
        'Sunday': isOpenSunday
            ? '${openingTimeSunday.format(context)} - ${closingTimeSunday.format(context)}'
            : 'Closed',
      },
      'ownerId': user.uid,
    });

    _showSuccessDialog(
        "Registration Successful", "Your shop has been registered successfully!");

    print('Navigating to dashboard');
    final routerDelegate = Router.of(context).routerDelegate;
    if (routerDelegate is AppRouterDelegate) {
      routerDelegate.navigateTo('/dashboard');
    } else {
      print('Failed to retrieve AppRouterDelegate');
    }

  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(title: Text('Shop Details')),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: isWideScreen ? screenWidth * 0.5 : screenWidth * 0.9,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Link to Existing Shop",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E7C4D), // Green color
                  ),
                ),
                SizedBox(height: 20),
                  Text(
                    "Register a New Shop",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E7C4D), // Green color
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _shopNameController,
                    decoration: InputDecoration(
                      labelText: "Shop Name",
                      hintText: "Enter your shop's name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: "Address",
                      hintText: "Enter your shop's address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: "City",
                      hintText: "Enter city",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedProvince,
                    decoration: InputDecoration(
                      labelText: "Province",
                      border: OutlineInputBorder(),
                    ),
                    items: provinces
                        .map((province) =>
                        DropdownMenuItem(child: Text(province), value: province))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProvince = newValue;
                      });
                    },
                    hint: Text('Select Province'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _zipController,
                    decoration: InputDecoration(
                      labelText: "Zip Code",
                      hintText: "Enter zip code",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Enter phone number (+92 XXX XXXXXXX)",
                      border: OutlineInputBorder(),
                      errorText: _phoneController.text.isNotEmpty &&
                          !_validatePhone(_phoneController.text)
                          ? 'Invalid phone number format'
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      hintText: "example@email.com",
                      border: OutlineInputBorder(),
                      errorText: _emailController.text.isNotEmpty &&
                          !_validateEmail(_emailController.text)
                          ? 'Invalid email format'
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 10),
                  SwitchListTile(
                    title: Text('Open on Monday',
                        style: GoogleFonts.montserrat(
                            fontSize: 16, color: Colors.black)),
                    value: isOpenMonday,
                    onChanged: (value) {
                      setState(() {
                        isOpenMonday = value;
                      });
                    },
                    activeColor: Color(0xFF1E7C4D),
                  ),
                  if (isOpenMonday) ...[
                    Text("Opening Time: ${openingTimeMonday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: openingTimeMonday,
                        );
                        if (picked != null && picked != openingTimeMonday) {
                          setState(() {
                            openingTimeMonday = picked;
                          });
                        }
                      },
                      child: Text('Select Opening Time',
                          style: GoogleFonts.montserrat()),
                    ),
                    Text("Closing Time: ${closingTimeMonday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: closingTimeMonday,
                        );
                        if (picked != null && picked != closingTimeMonday) {
                          setState(() {
                            closingTimeMonday = picked;
                          });
                        }
                      },
                      child: Text('Select Closing Time',
                          style: GoogleFonts.montserrat()),
                    ),
                  ],
                  SwitchListTile(
                    title: Text('Open on Tuesday',
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black)),
                    value: isOpenTuesday,
                    onChanged: (value) {
                      setState(() {
                        isOpenTuesday = value;
                      });
                    },
                    activeColor: Color(0xFF1E7C4D),
                  ),
                  if (isOpenTuesday) ...[
                    Text("Opening Time: ${openingTimeTuesday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: openingTimeTuesday,
                        );
                        if (picked != null && picked != openingTimeTuesday) {
                          setState(() {
                            openingTimeTuesday = picked;
                          });
                        }
                      },
                      child: Text('Select Opening Time', style: GoogleFonts.montserrat()),
                    ),
                    Text("Closing Time: ${closingTimeTuesday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: closingTimeTuesday,
                        );
                        if (picked != null && picked != closingTimeTuesday) {
                          setState(() {
                            closingTimeTuesday = picked;
                          });
                        }
                      },
                      child: Text('Select Closing Time', style: GoogleFonts.montserrat()),
                    ),
                  ],
                  SwitchListTile(
                    title: Text('Open on Wednesday',
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black)),
                    value: isOpenWednesday,
                    onChanged: (value) {
                      setState(() {
                        isOpenWednesday = value;
                      });
                    },
                    activeColor: Color(0xFF1E7C4D),
                  ),
                  if (isOpenWednesday) ...[
                    Text("Opening Time: ${openingTimeWednesday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: openingTimeWednesday,
                        );
                        if (picked != null && picked != openingTimeWednesday) {
                          setState(() {
                            openingTimeWednesday = picked;
                          });
                        }
                      },
                      child: Text('Select Opening Time', style: GoogleFonts.montserrat()),
                    ),
                    Text("Closing Time: ${closingTimeWednesday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: closingTimeWednesday,
                        );
                        if (picked != null && picked != closingTimeWednesday) {
                          setState(() {
                            closingTimeWednesday = picked;
                          });
                        }
                      },
                      child: Text('Select Closing Time', style: GoogleFonts.montserrat()),
                    ),
                  ],
                  SwitchListTile(
                    title: Text('Open on Thursday',
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black)),
                    value: isOpenThursday,
                    onChanged: (value) {
                      setState(() {
                        isOpenThursday = value;
                      });
                    },
                    activeColor: Color(0xFF1E7C4D),
                  ),
                  if (isOpenThursday) ...[
                    Text("Opening Time: ${openingTimeThursday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: openingTimeThursday,
                        );
                        if (picked != null && picked != openingTimeThursday) {
                          setState(() {
                            openingTimeThursday = picked;
                          });
                        }
                      },
                      child: Text('Select Opening Time', style: GoogleFonts.montserrat()),
                    ),
                    Text("Closing Time: ${closingTimeThursday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: closingTimeThursday,
                        );
                        if (picked != null && picked != closingTimeThursday) {
                          setState(() {
                            closingTimeThursday = picked;
                          });
                        }
                      },
                      child: Text('Select Closing Time', style: GoogleFonts.montserrat()),
                    ),
                  ],
                  SwitchListTile(
                    title: Text('Open on Friday',
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black)),
                    value: isOpenFriday,
                    onChanged: (value) {
                      setState(() {
                        isOpenFriday = value;
                      });
                    },
                    activeColor: Color(0xFF1E7C4D),
                  ),
                  if (isOpenFriday) ...[
                    Text("Opening Time: ${openingTimeFriday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: openingTimeFriday,
                        );
                        if (picked != null && picked != openingTimeFriday) {
                          setState(() {
                            openingTimeFriday = picked;
                          });
                        }
                      },
                      child: Text('Select Opening Time', style: GoogleFonts.montserrat()),
                    ),
                    Text("Closing Time: ${closingTimeFriday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: closingTimeFriday,
                        );
                        if (picked != null && picked != closingTimeFriday) {
                          setState(() {
                            closingTimeFriday = picked;
                          });
                        }
                      },
                      child: Text('Select Closing Time', style: GoogleFonts.montserrat()),
                    ),
                  ],

                  SwitchListTile(
                    title: Text('Open on Saturday',
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black)),
                    value: isOpenSaturday,
                    onChanged: (value) {
                      setState(() {
                        isOpenSaturday = value;
                      });
                    },
                    activeColor: Color(0xFF1E7C4D),
                  ),
                  if (isOpenSaturday) ...[
                    Text("Opening Time: ${openingTimeSaturday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: openingTimeSaturday,
                        );
                        if (picked != null && picked != openingTimeSaturday) {
                          setState(() {
                            openingTimeSaturday = picked;
                          });
                        }
                      },
                      child: Text('Select Opening Time', style: GoogleFonts.montserrat()),
                    ),
                    Text("Closing Time: ${closingTimeSaturday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: closingTimeSaturday,
                        );
                        if (picked != null && picked != closingTimeSaturday) {
                          setState(() {
                            closingTimeSaturday = picked;
                          });
                        }
                      },
                      child: Text('Select Closing Time', style: GoogleFonts.montserrat()),
                    ),
                  ],

                  SwitchListTile(
                    title: Text('Open on Sunday',
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black)),
                    value: isOpenSunday,
                    onChanged: (value) {
                      setState(() {
                        isOpenSunday = value;
                      });
                    },
                    activeColor: Color(0xFF1E7C4D),
                  ),
                  if (isOpenSunday) ...[
                    Text("Opening Time: ${openingTimeSunday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: openingTimeSunday,
                        );
                        if (picked != null && picked != openingTimeSunday) {
                          setState(() {
                            openingTimeSunday = picked;
                          });
                        }
                      },
                      child: Text('Select Opening Time', style: GoogleFonts.montserrat()),
                    ),
                    Text("Closing Time: ${closingTimeSunday.format(context)}",
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: closingTimeSunday,
                        );
                        if (picked != null && picked != closingTimeSunday) {
                          setState(() {
                            closingTimeSunday = picked;
                          });
                        }
                      },
                      child: Text('Select Closing Time', style: GoogleFonts.montserrat()),
                    ),
                  ],
                  // Add other days similarly (Tuesday, Wednesday, etc.)
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerNewShop,
                    child: Text('Register Shop',
                        style: GoogleFonts.montserrat(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: GoogleFonts.montserrat(fontSize: 16),
                      backgroundColor: Color(0xFF1E7C4D), // Green button
                    ),
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}
