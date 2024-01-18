import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  // Define controllers for the text
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  // Add state for the permission radio buttons or switches if desired

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        toolbarHeight: 75,
        elevation: 0,
        centerTitle: true,
      ),
    extendBodyBehindAppBar: false,
    body: Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
      image: AssetImage('assets/App_Splash_Screen1.jpg'),
      fit: BoxFit.cover,
      ),
    ),
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username', filled: true, fillColor: Colors.white70,),
            ),
            const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', filled: true, fillColor: Colors.white70),
              ),
            const SizedBox(height: 10),
            TextField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(labelText: 'Phone Number', filled: true, fillColor: Colors.white70),
            keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.white70),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.white70),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password', filled: true, fillColor: Colors.white70),
              obscureText: true,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              child: const Text('Sign Up', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // make the button larger
              ),
              onPressed: () async {
                if (_passwordController.text == _confirmPasswordController.text) {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    // If the sign up is successful, navigate to the login_screen
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  } on FirebaseAuthException catch (e) {
                    // Handle different Firebase auth errors
                  } catch (e) {
                    // Handle other errors
                  }
                } else {
                  // Handle the error if the passwords don't match
                }
              },
            ),
          ],
        ),
      ),
    )
    )
    );
  }
}