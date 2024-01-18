import 'package:flutter/material.dart';
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
              onTap: () {
                // TODO: Implement location permission prompt
              },
              onSubmitted: (value) {
                // TODO: Implement and navigate to details screen search functionality
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailsScreen()));
                //child: GoogleMap(), // Placeholder for Google Map widget
              },
            ),
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