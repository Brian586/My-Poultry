import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/Authentication/login.dart';
import 'package:my_poultry/Config/config.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String username = "";
  String url = "";
  String email = "";

  @override
  void initState() {
    super.initState();

    getInfo();
  }

  getInfo() async {
    username = MyPoultry.sharedPreferences.getString(MyPoultry.userName);
    url = MyPoultry.sharedPreferences.getString(MyPoultry.userAvatarUrl);
    email = MyPoultry.sharedPreferences.getString(MyPoultry.userEmail);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
        child: Text("Home"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(url),
                    radius: 40.0,
                  ),
                  SizedBox(height: 10.0,),
                  Text(
                    username,
                    style: GoogleFonts.fredokaOne(color: Colors.black, fontSize: 17.0, ),
                  ),
                  Text(
                    email,
                    style:  TextStyle(color: Colors.brown, fontSize: 15.0, ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.grey,),
              title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            ListTile(
              leading: Icon(Icons.medical_services_outlined, color: Colors.grey,),
              title: Text("Vaccination", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings, color: Colors.grey,),
              title: Text("Experts", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.grey,),
              title: Text("Groups", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            ListTile(
              leading: Icon(Icons.outdoor_grill_outlined, color: Colors.grey,),
              title: Text("Produce", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey,),
              title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.grey,),
              title: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold),),
              onTap: () {
                MyPoultry.auth.signOut().then((c) {
                  Route route = MaterialPageRoute(builder: (context)=> Login());
                  Navigator.pushReplacement(context, route);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
