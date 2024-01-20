import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'details_screen.dart'; // Make sure to create this Dart file
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int userDefaultRadius = 5; // Fallback default value

  @override
  void initState() {
    super.initState();
    fetchUserDefaultRadius();
  }

  Future<void> fetchUserDefaultRadius() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data()! as Map<String, dynamic>;
        setState(() {
          userDefaultRadius = userData['searchRadius'] ?? 5; // Assuming 'searchRadius' is stored in Firestore
        });
      }
    }
  }

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
                  GeoPoint? location;
                  if (isUsername(value)) {
                    location = await fetchUserLastLocation(value);
                  } else {
                    location = await getCoordinatesFromAddress(value);
                  }
                  if (location != null) {
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsScreen(midpoint: location, defaultSearchRadius: userDefaultRadius,)));
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
  Future<GeoPoint?> getCoordinatesFromAddress(String address) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=AIzaSyDdwUQbRqcF1RRsl0PKJgUNNFHpvHPLOU0');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['results'].isNotEmpty) {
        final location = jsonResponse['results'][0]['geometry']['location'];
        return GeoPoint(location['lat'], location['lng']);
      }
    }
    return null;
  }
}

