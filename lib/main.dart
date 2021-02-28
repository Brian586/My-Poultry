import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/Authentication/login.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/Counters/changeAddresss.dart';
import 'package:my_poultry/pages/home.dart';
import 'package:provider/provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => AddressChanger()),
      ],
      child: DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
          primarySwatch: Colors.pink,
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: SplashScreen(),
          );
        },
      ),
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
