import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

@override
Widget build(BuildContext context) {
// TODO: Insert details logic here
return Scaffold(
appBar: AppBar(
title: const Text('Details'),
),
body: Column(
children: <Widget>[
// Placeholder for location details
ListTile(
title: const Text('Location Name'),
subtitle: const Text('Location Address'),
// When tapped, navigate to the Navigation Screen
onTap: () {
// TODO: Implement navigation to the location
},),
// Placeholder for more locations
],
),
);
}}