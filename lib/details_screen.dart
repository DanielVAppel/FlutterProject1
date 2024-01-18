import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'profile_page.dart';

class DetailsScreen extends StatelessWidget {
  final GeoPoint midpoint; // Replace with actual type for midpoint
  const DetailsScreen({super.key, required this.midpoint});

  @override
  Widget build(BuildContext context) {
    // Assuming you have variables for the midpoint coordinates and search radius
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMapWidget(midpoint: midpoint), // Placeholder for Google Map centered on the midpoint
          ),
          SearchRadiusWidget(), // Widget to display and change the search radius
          Expanded(
            child: NearbyLocationsList(midpoint: midpoint), // List of nearby locations
          ),
        ],
      ),
    );
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