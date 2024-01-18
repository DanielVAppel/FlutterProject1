import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'details_screen.dart'; // Make sure to create this Dart file
import 'profile_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Midway Mapper', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent, // Set the desired AppBar color
        toolbarHeight: 55,
        automaticallyImplyLeading: false, // Prevents the back arrow
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings, size: 40),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white, //sets background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search', labelStyle: TextStyle(
                  fontSize: 20),
                suffixIcon: Icon(Icons.search, size: 25,),
              ),
              onTap: () async {
                var status = await Permission.location.request();
                if (status.isGranted) {
                  // Location permission granted
                  print("Location permission granted");
                } else {
                  // Handle location permission denied
                  print("Location permission denied");
                }
              },
              onSubmitted: (value) async {
                // TODO: Implement and navigate to details screen search functionality
                if (isUsername(value)) {
                  // Handle username search
                  // Fetch user's last known location
                } else {
                  // Handle location search
                  // Use a geocoding service to find the location coordinates
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const DetailsScreen(midpoint: GeoPoint(14,14),)));//This might need some editing
                  //child: GoogleMap(), // Placeholder for Google Map widget
                };
              }),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Find the MidPoint by selecting a friend or location to get started.",
                style: TextStyle(fontSize: 24.0),
              ),
              ),
             Expanded(
              child: Image.asset('assets/animated_globe.gif',
                fit: BoxFit.cover,
            ),
    ),

          ],
        ),
      ),
    );
  }
  bool isUsername(String input) {
    // Example logic: Check if the input matches username criteria
    // This is a placeholder - adjust according to your app's username rules
    return RegExp(r"^[a-zA-Z0-9_]+$").hasMatch(input);
  }
  Future<GeoPoint?> fetchUserLastLocation(String username) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data()['lastLocation']; // Assuming 'lastLocation' is stored as GeoPoint
      }
    } catch (e) {
      print("Error fetching user location: $e");
    }
    return null;
  }
}

// // Placeholder widget for Google Map
// class GoogleMap extends StatelessWidget {
//   const GoogleMap({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Map Placeholder'));
//   }
// }