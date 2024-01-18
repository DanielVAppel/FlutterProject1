import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'friend_list.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  int searchRadius = 5; // Default value
  String username = 'username'; // Placeholder for current username

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
  Future<void> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data()! as Map<String, dynamic>;
        setState(() {
          username = userData['username'] ?? 'Unavailable';
          searchRadius = userData['searchRadius'] ?? 5; // Assuming 'searchRadius' is stored in Firestore

        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        toolbarHeight: 75,
        leading: IconButton(
          icon: const Icon(Icons.home, size: 40,),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Friends List', style: TextStyle(fontSize: 20)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendList())),
            ),
            ListTile(
              title: const Text('Default Search Radius:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text('$searchRadius miles', style: const TextStyle(fontSize: 16)),
              onTap: _changeSearchRadius,
            ),
            ListTile(
              title: const Text('Edit Username:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text(username, style: const TextStyle(fontSize: 16)),
              onTap: _changeUsername,
            ),
            // Add more settings or options as needed
          ],
        ),
      ),
    );
  }

  Future<void> _changeUsername() async {
    String? newUsername = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      String? localUsername;
      return AlertDialog(
        title: const Text('Change Username'),
        content: TextField(
          onChanged: (value) => localUsername = value,
          decoration: const InputDecoration(hintText: "Enter new username"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(localUsername),
          ),
        ],
      );
    },
  );

  if (newUsername != null && newUsername.isNotEmpty) {
    // Update username in Firebase
    // Example: Update the username in Firebase Firestore
    var user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({'username': newUsername});

    // Update the local state
    setState(() => username = newUsername);
  }
  }
  Future<void> _changeSearchRadius() async {
    int? newRadius = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int localRadius = searchRadius; // Use current search radius as initial value
        return AlertDialog(
          title: const Text('Change Search Radius'),
          content: TextField(
            onChanged: (value) {
              if (value.isNotEmpty) {
                localRadius = int.tryParse(value) ?? searchRadius;
              }
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "$searchRadius miles"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(localRadius),
            ),
          ],
        );
      },
    );

    if (newRadius != null && newRadius != searchRadius) {
      // Update the radius in Firestore and local state
      await updateSearchRadius(newRadius);
    }
  }

  Future<void> updateSearchRadius(int newRadius) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Update in Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'searchRadius': newRadius
      });
      // Update local state
      setState(() {
        searchRadius = newRadius;
      });
    }
  }}