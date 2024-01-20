import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'details_screen.dart';

class NavigationScreen extends StatelessWidget {
  final Place destination;
  static const LatLng calPolyPomonaCords = LatLng(34.0569, -117.8217); // Cal Poly Pomona coordinates

  const NavigationScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Directions to ${destination.name}'),
        // Other AppBar properties
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDirections(calPolyPomonaCords, destination.location),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const Text('No directions found.');
          }

          final steps = snapshot.data!['routes'][0]['legs'][0]['steps'] as List;
          return ListView.builder(
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return ListTile(
                title: Text((step['html_instructions'] as String).replaceAll(RegExp(r'<[^>]*>'), '')),
                subtitle: Text('${step['distance']['text']} - ${step['duration']['text']}'),
              );
            },
          );
        },
      ),
    );
  }
}
Future<Map<String, dynamic>> fetchDirections(LatLng origin, LatLng destination) async {
  final url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=YOUR_API_KEY');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load directions');
  }
}