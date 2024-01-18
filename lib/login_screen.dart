import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        centerTitle: true, // Center the title
        backgroundColor: Colors.redAccent, // You can set this to any color you like
        elevation: 0, // Removes shadow under the app bar
        toolbarHeight: 75, // Increase the AppBar height if needed
        title: const SizedBox(
          height: 150,
          child: Center(
              child:Text('Log In', style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold)),
          ),),),
      extendBodyBehindAppBar: false, // Allows the body to extend behind the AppBar
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/App_Splash_Screen1.jpg'),//Background image
            fit: BoxFit.cover,
          )
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 80.0),// Add padding to account for the AppBar
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    const SizedBox(height: 50), //Space between "Log In" and the text fields
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.white70,),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10), // Space between the email and password fields
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white70,),
                      obscureText: true,
                    ),
                    const SizedBox(height: 40), // Space between password field and buttons

                    ElevatedButton(
                      child: const Text('Sign In', style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // make the button larger
                      ),
                      onPressed: () async {
                        try {
                          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          // If the sign in is successful, navigate to the HomeScreen
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                        } on FirebaseAuthException catch (e) {
                          // Handle different Firebase auth errors
                        } catch (e) {
                          // Handle other errors
                        }
                      },
                    ),
                    const SizedBox(height: 20), // Space between Sign In and Sign Up buttons
                    ElevatedButton(
                      child: const Text('Sign Up', style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // make the button larger
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    );
  }
}

