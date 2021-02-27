import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/Authentication/login.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/pages/agrovetProducts.dart';
import 'package:my_poultry/pages/counter.dart';
import 'package:my_poultry/pages/vaccinationPage.dart';


class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

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
    return Drawer(
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
            onTap: () {
              Route route = MaterialPageRoute(builder: (context)=> CounterPage());
              Navigator.push(context, route);
            },
            leading: Icon(Icons.countertops_outlined, color: Colors.grey,),
            title: Text("Counter", style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.outdoor_grill_outlined, color: Colors.grey,),
            title: Text("Produce", style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.local_hospital_outlined, color: Colors.grey,),
            title: Text("Health", style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            onTap: () {
              Route route = MaterialPageRoute(builder: (context)=> AgrovetProducts());
              Navigator.push(context, route);
            },
            leading: Icon(Icons.shopping_bag_outlined, color: Colors.grey,),
            title: Text("Agrovet Products", style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.people, color: Colors.grey,),
            title: Text("Groups", style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings_outlined, color: Colors.grey,),
            title: Text("Experts", style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          ListTile(
            onTap: () {
              Route route = MaterialPageRoute(builder: (context)=> VaccinationPage());
              Navigator.push(context, route);
            },
            leading: Icon(Icons.medical_services_outlined, color: Colors.grey,),
            title: Text("Vaccination", style: TextStyle(fontWeight: FontWeight.bold),),
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
    );
  }
}
