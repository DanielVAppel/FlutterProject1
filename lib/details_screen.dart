import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'navigation_screen.dart';
import 'profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DetailsScreen extends StatelessWidget {
  final GeoPoint? midpoint; // Replace with actual type for midpoint
  final int defaultSearchRadius; // Added field for default search radius
  const DetailsScreen({super.key, required this.midpoint, required this.defaultSearchRadius});

  @override
  Widget build(BuildContext context) {
    // Assuming you have variables for the midpoint coordinates and search radius
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title
        backgroundColor: Colors.redAccent, // You can set this to any color you like
        elevation: 0, // Removes shadow under the app bar
        toolbarHeight: 75, // Increase the AppBar height if needed
        //, style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
        title: const Text('Details', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMapWidget(midpoint: midpoint), // Placeholder for Google Map centered on the midpoint
          ),
          SearchRadiusWidget(
            defaultRadius: defaultSearchRadius,
            onRadiusChange: (newRadius) {
            // Handle radius change
              // Update the nearby places list based on new radius

            },),
          // Widget to display and change the search radius
          Expanded(
            child: NearbyLocationsList(
                midpoint: midpoint, searchRadius: defaultSearchRadius), // List of nearby locations
          ),
        ],
      ),
    );
  }
}
class GoogleMapWidget extends StatelessWidget {
  final GeoPoint? midpoint;

  const GoogleMapWidget({super.key, this.midpoint});

  @override
  Widget build(BuildContext context) {
    final initialCameraPosition = CameraPosition(
      target: LatLng(midpoint?.latitude ?? 0, midpoint?.longitude ?? 0),
      zoom: 14,
    );

    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      markers: {
        if (midpoint != null)
          Marker(
            markerId: const MarkerId('midpoint'),
            position: LatLng(midpoint!.latitude, midpoint!.longitude),
          ),
      },
    );
  }
}

class SearchRadiusWidget extends StatefulWidget {
  final int defaultRadius;
  final Function(int) onRadiusChange;

  const SearchRadiusWidget({super.key, required this.defaultRadius, required this.onRadiusChange,});

  @override
  _SearchRadiusWidgetState createState() => _SearchRadiusWidgetState();
}

class _SearchRadiusWidgetState extends State<SearchRadiusWidget> {
  late int currentRadius;
  @override
  void initState() {
    super.initState();
    currentRadius = widget.defaultRadius; // Initialize with default radius
  }
  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: currentRadius,
      items: [1, 5, 10, 20].map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value miles'),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          currentRadius = newValue ?? currentRadius;
        });
        widget.onRadiusChange(currentRadius);
      },
    );
  }
}

class NearbyLocationsList extends StatelessWidget {
  final GeoPoint? midpoint;
  final int searchRadius; // Added field for search radius

  const NearbyLocationsList({Key? key, this.midpoint, required this.searchRadius}) : super(key: key);

  // Fetch locations from Google Places API
  Future<List<Place>> fetchNearbyPlaces() async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${midpoint?.latitude},${midpoint?.longitude}&radius=5&key=AIzaSyDdwUQbRqcF1RRsl0PKJgUNNFHpvHPLOU0');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final places = jsonResponse['results'] as List;
      return places.map((placeJson) => Place.fromJson(placeJson)).toList();
    } else {
      throw Exception('Failed to load nearby places');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Place>>(
      future: fetchNearbyPlaces(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No places found.');
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final place = snapshot.data![index];
            return ListTile(
              title: Text(place.name),
              // Other place details
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => NavigationScreen(destination: place)));
              },
            );
          },
        );
      },
    );
  }
}

class Place {
  final String name;
  final LatLng location; // Assuming you are using LatLng to store location

  Place({required this.name, required this.location});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      location: LatLng(
        json['geometry']['location']['lat'],
        json['geometry']['location']['lng'],
      ),
    );
  }
}