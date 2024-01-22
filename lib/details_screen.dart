import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'navigation_screen.dart';
import 'profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DetailsScreen extends StatefulWidget {
  final GeoPoint? midpoint; // Replace with actual type for midpoint
  final int defaultSearchRadius; // Added field for default search radius

  const DetailsScreen({super.key, required this.midpoint, required this.defaultSearchRadius});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}
class _DetailsScreenState extends State<DetailsScreen> {
  late int currentSearchRadius;
  String cityName = '';// This will hold the city name once fetched
  bool isCityNameLoading  = false;// To track if the city name is being loaded

  @override
  void initState() {
    super.initState();
    currentSearchRadius = widget.defaultSearchRadius;
    if (widget.midpoint != null) {
      _getCityNameFromCoordinates(widget.midpoint!);// Call the method to fetch city name
    }
  }
  Future<void> _getCityNameFromCoordinates(GeoPoint point) async {
    setState(() {
      isCityNameLoading = true;
    });
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${point.latitude},${point.longitude}&key=AIzaSyDdwUQbRqcF1RRsl0PKJgUNNFHpvHPLOU0Y',
    );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final results = jsonResponse['results'] as List<dynamic>;
        // Find the locality in the results
        for (var result in results) {
          for (var component in result['address_components']) {
            if (component['types'].contains('locality')) {
              setState(() {
                cityName = component['long_name'];
                isCityNameLoading = false;
              });
              return;
            }
          }
        }
      } else {
        // Handle error or no locality found
        setState(() {
          isCityNameLoading = false;
        });
      }

   }
  Future<List<Place>> fetchNearbyPlaces() async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${widget.midpoint?.latitude},${widget.midpoint?.longitude}&radius=${currentSearchRadius* 1609.34}&type=restaurant|entertainment&key=AIzaSyDdwUQbRqcF1RRsl0PKJgUNNFHpvHPLOU0',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final places = jsonResponse['results'] as List;
      return places.map((placeJson) => Place.fromJson(placeJson)).toList();
    } else {
      throw Exception('Failed to load nearby places');
    }
  }

  void onRadiusChange(int newRadius) {
    if (newRadius > 0) {
    setState(() {
      currentSearchRadius = newRadius;
    });
  }else {
      // Handle the error case for non-positive integers
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Radius'),
            content: const Text('Please enter a positive integer for the radius.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

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
          if (isCityNameLoading)
            CircularProgressIndicator() // Show loading indicator while fetching city name
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your Mid-Point is: $cityName', // Display the city name
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          // isLoadingCityName
          //     ? const CircularProgressIndicator() // Show loading indicator while fetching city name
          //     : Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     'Your Mid-Point is: $cityName', // Display the city name
          //     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          //   ),
          ),
          // Expanded(
          //   child: GoogleMapWidget(midpoint: widget.midpoint), // Placeholder for Google Map centered on the midpoint
          // ),
          SearchRadiusWidget(
            defaultRadius: currentSearchRadius,
            onRadiusChange: onRadiusChange,

            ),
          // Widget to display and change the search radius
          Expanded(
            child: FutureBuilder<List<Place>>(
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
                    return Container(
                        margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.5),
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: ListTile(
                      title: Text(place.name, style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NavigationScreen(destination: place),
                          ),
                        );
                      },
                    ));
                  },
                );
              },
            ),
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
  final TextEditingController _radiusController = TextEditingController();
  Timer? _debounce;

  //late int currentRadius;
  @override
  void initState() {
    super.initState();
    // Set the default radius as the initial text in the TextField
    _radiusController.text = widget.defaultRadius.toString();

  }

  @override
  void dispose() {
    _debounce?.cancel();
    _radiusController.dispose();
    super.dispose();
  }
  void _onSearchRadiusChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final int? radius = int.tryParse(value);
      if (radius != null && radius > 0) {
        widget.onRadiusChange(radius);
      } else {
        // Handle invalid input
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a positive integer for the radius.'),
          ),
        );
      }
    });
  }
  void _onSubmitted(String value) {
    final int? radius = int.tryParse(value);
    if (radius != null && radius > 0) {
      widget.onRadiusChange(radius);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('Please enter a positive integer for the radius.'),
    duration: Duration(seconds: 2),),);
    }
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _radiusController,
      decoration: const InputDecoration(
        labelText: 'Search Radius (miles)', labelStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onSubmitted: _onSubmitted,
      onChanged: _onSearchRadiusChanged, // Optionally update as the user types
    );
  }
}

class NearbyLocationsList extends StatelessWidget {
  final GeoPoint? midpoint;
  final int searchRadius; // Added field for search radius

  const NearbyLocationsList({Key? key, this.midpoint, required this.searchRadius}) : super(key: key);

  // Fetch locations from Google Places API
  Future<List<Place>> fetchNearbyPlaces() async {
    //final url = Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${midpoint?.latitude},${midpoint?.longitude}$searchRadius&type=restaurant|entertainment&key=AIzaSyDdwUQbRqcF1RRsl0PKJgUNNFHpvHPLOU0');//TODO take this value, calculate distance from current home value, then divide by two and get that place.
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${midpoint?.latitude},${midpoint?.longitude}&radius=${searchRadius * 1609.34}&keyword=restaurant|entertainment&key=AIzaSyDdwUQbRqcF1RRsl0PKJgUNNFHpvHPLOU0',);
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
  Future<String> getCityNameFromCoordinates(GeoPoint point) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${point.latitude},${point.longitude}&key=YOUR_API_KEY',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final cityName = jsonResponse['results'][0]['address_components'].firstWhere(
            (component) => component['types'].contains('locality'),
      )['long_name'];
      return cityName;
    } else {
      throw Exception('Failed to get city name');
    }
  }
}