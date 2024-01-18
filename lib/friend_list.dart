import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_screen.dart'; // Make sure to create this Dart file
import 'profile_page.dart';

class FriendList extends StatefulWidget {
  const FriendList({super.key});

  @override
  FriendListState createState() => FriendListState();
}

class FriendListState extends State<FriendList> {
  final TextEditingController _searchController = TextEditingController();
  List<String> friends = []; // Placeholder for friends list
  List<String> friendRequests = []; // Placeholder for friend requests

  @override
  void initState() {
    super.initState();
    fetchFriendsList();
    fetchFriendRequests();
  }

  Future<void> fetchFriendsList() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          friends = List<String>.from(userData['friends'] ?? []);
        });
      }
    }
}

  Future<void> fetchFriendRequests() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          friendRequests = List<String>.from(userData['friendRequests'] ?? []);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends List', style: TextStyle(fontSize: 47, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        toolbarHeight: 75,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home , size: 40),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Friend Requests Section
            Expanded(
              child: ListView.builder(
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(friendRequests[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            // Accept Friend Request
                            acceptFriendRequest(friendRequests[index]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            // Deny friend request
                            denyFriendRequest(friendRequests[index]);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Friend Search Bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Add Friend',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) async {
                await searchAndAddFriend(value, context);
              },
            ),
            // Friends List Section
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(friends[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        // Remove friend
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> acceptFriendRequest(String friendUserId) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Add each other as friends
      FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'friends': FieldValue.arrayUnion([friendUserId])
      });
      FirebaseFirestore.instance.collection('users').doc(friendUserId).update({
        'friends': FieldValue.arrayUnion([currentUser.uid])
      });

      // Remove the friend request
      FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'friendRequests': FieldValue.arrayRemove([friendUserId])
      });

      // Update local state
      setState(() {
        friends.add(friendUserId);
        friendRequests.remove(friendUserId);
      });
    }
  }

  Future<void> denyFriendRequest(String friendUserId) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Remove the friend request
      FirebaseFirestore.instance.collection('users')
          .doc(currentUser.uid)
          .update({
        'friendRequests': FieldValue.arrayRemove([friendUserId])
      });

      // Update local state
      setState(() {
        friendRequests.remove(friendUserId);
      });
    }}

  Future<void> searchAndAddFriend(String searchQuery, BuildContext context) async {
    var searchResults = await searchUsers(searchQuery);
    // Assuming searchResults is a list of user documents with at least 'uid' and 'username'
    // Check if the widget is still in the widget tree
    if (!mounted) return;
    // Display the search results and let the user choose a user to send a friend request
    // For simplicity, using a dialog
    String? selectedUserId = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select a user to add'),
          children: searchResults.map((user) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, user['uid']),
              child: Text(user['username']),
            );
          }).toList(),
        );
      },
    );

    if (selectedUserId != null) {
      // Send a friend request
      // Add selectedUserId to the current user's friendRequests list in Firestore
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && selectedUserId != currentUser.uid) {
        await FirebaseFirestore.instance.collection('users').doc(selectedUserId).update({
          'friendRequests': FieldValue.arrayUnion([currentUser.uid])
        });
        fetchFriendRequests();
      }
    }}
    Future<List<Map<String, dynamic>>> searchUsers(String searchQuery) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: searchQuery)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return []; // Return an empty list if no results
      }
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }}


