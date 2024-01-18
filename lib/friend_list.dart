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
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final TextEditingController _searchController = TextEditingController();
  List<String> friends = [];//placeholder for friends list

  @override
  void initState() {
    super.initState();
    fetchFriendsList();
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
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Add Friend', labelStyle: TextStyle(
                  fontSize: 20),
                suffixIcon: Icon(Icons.search, size: 25,),
              ),
              onSubmitted: (value) async {
                var searchResults = await searchUsers(value);
                // TODO: Implement friend search logic
                // You might want to update your state and display these users in a list.
                // Users can then be added as friends by updating Firestore records.
              },
            ),
            const SizedBox(height: 20), // Space between button and search bar
            ElevatedButton(
              child: const Text('Find Friends in Contacts',style: TextStyle(fontSize: 20,)),
              onPressed: () async {
                // TODO: Implement contact list permission request and friend matching logic
                await requestContactsPermission();
                await findFriendsInContacts();
              },
            ),
            // TODO: Display the list of friends
            // For each friend, display their name, a default user icon, and an 'X' button to remove them
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  String friendUsername = friends[index];
                  return ListTile(
                    leading: const Icon(Icons.person), // Default user icon
                    title: Text(friendUsername),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        String friendToRemove = friends[index];
                      // Implement friend removal logic
                        // Example: Remove 'friendToRemove' from the current user's friend list in Firestore
                        // TODO: Remove friend from Firebase
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
  Future<void> fetchFriendsList() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          friends = List<String>.from(userData['friends'] ?? []);
        });
      }
    }
  }
  Future<List<Map<String, dynamic>>> searchUsers(String searchQuery) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: searchQuery)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> requestContactsPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }

  Future<void> findFriendsInContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    List<String> contactNumbers = contacts
        .map((contact) => contact.phones?.first.value ?? '')
        .where((number)=> number.isNotEmpty)
        .toList();

    // TODO: Use contactNumbers to find matching users in Firebase
    // This might involve querying users collection where 'phoneNumber' is in contactNumbers
  }
}