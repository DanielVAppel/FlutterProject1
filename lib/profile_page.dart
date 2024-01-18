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
  String username = "CurrentUsername"; // Placeholder for current username

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
    String? newRadius = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      String? localRadius;
      return AlertDialog(
        title: const Text('Change Search Radius'),
        content: TextField(
          onChanged: (value) => localRadius = value,
          decoration: const InputDecoration(hintText: "Enter new radius (miles)"),
          keyboardType: TextInputType.number,
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

  if (newRadius != null && int.tryParse(newRadius) != null) {
    // Update search radius in Firebase and local state
    var user = FirebaseAuth.instance.currentUser;
    int radius = int.parse(newRadius);
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({'searchRadius': radius});
    setState(() => searchRadius = radius);
  }
  }
}

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   int searchRadius = 5; // Default value
//   String username = "CurrentUsername"; // Placeholder for current username
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Profile', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.redAccent,
//         toolbarHeight: 75,
//         leading: IconButton(
//           icon: const Icon(Icons.home),
//           onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             ElevatedButton(
//               child: const Text('Friends List'),
//               onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendList())), // Navigate to FriendList screen
//             ),
//             ListTile(
//               title: const Text('Default Search Radius'),
//               subtitle: Text('$searchRadius miles'),
//               onTap: () async {
//                 // Implement the logic to change the search radius
//               },
//             ),
//             ListTile(
//               title: const Text('Edit Username'),
//               subtitle: Text(username),
//               onTap: () async {
//                 // Implement the logic to change the username
//               },
//             ),
//             // Add more settings or options as needed
//           ],
//         ),
//       ),
//     );
//   }
// }
//

//
// Future<void> _changeSearchRadius() async {
//   String? newRadius = await showDialog<String>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Change Search Radius'),
//         content: TextField(
//           onChanged: (value) => newRadius = value,
//           decoration: const InputDecoration(hintText: "Enter new radius (miles)"),
//           keyboardType: TextInputType.number,
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('CANCEL'),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () => Navigator.of(context).pop(newRadius),
//           ),
//         ],
//       );
//     },
//   );
//
//   if (newRadius != null && int.tryParse(newRadius!) != null) {
//     // Update search radius in Firebase and local state
//     var user = FirebaseAuth.instance.currentUser;
//     int radius = int.parse(newRadius!);
//     await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({'searchRadius': radius});
//     setState(() => searchRadius = radius);
//   }
// }