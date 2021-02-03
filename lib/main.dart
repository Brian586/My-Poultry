import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/Authentication/login.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  MyPoultry.auth = FirebaseAuth.instance;
  MyPoultry.sharedPreferences = await SharedPreferences.getInstance();
  MyPoultry.firestore = Firestore.instance;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen>
{

  @override
  void initState() {
    super.initState();

    displaySplash();
  }

  displaySplash() {
    Timer(Duration(seconds: 5), () async {
      if(await MyPoultry.auth.currentUser() != null)
      {
        Route route = MaterialPageRoute(builder: (_) => Home());
        Navigator.pushReplacement(context, route);
      }
      else
      {
        Route route = MaterialPageRoute(builder: (_) => Login());
        Navigator.pushReplacement(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Center(
        child: Text("My Poultry", style: GoogleFonts.fredokaOne(color: Colors.pink, fontSize: 20.0),),
      ),
    );
  }


}
