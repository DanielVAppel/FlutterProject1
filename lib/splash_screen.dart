import 'package:flutter/material.dart';
import 'login_screen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    //Here you can set what ever background color you need.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1), // Adjust the padding to position the image at the top
        alignment: Alignment.topCenter, // Align the content to the top of the screen
        child: const Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/App_Splash_Screen1.jpg'),
              width: 400, // Set the image width
              height: 400, // Set the image height
              fit: BoxFit
                  .contain, // Use this to adjust how the image fits into the allotted space
            ),
            Text('Midway Mapper', style: TextStyle(
                fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.black),),
  ],
        )
      )
    );
  }}
