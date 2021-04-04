import 'package:flutter/material.dart';
import 'package:my_poultry/expert/messagesHome.dart';
import 'package:my_poultry/pages/agrovetProducts.dart';
import 'package:my_poultry/pages/home.dart';
import 'package:my_poultry/pages/productPage.dart';


class ExpertHome extends StatefulWidget {

  final String name;
  final String phone;
  final String userID;

  ExpertHome({this.name, this.phone, this.userID});
  
  @override
  _ExpertHomeState createState() => _ExpertHomeState();
}

class _ExpertHomeState extends State<ExpertHome> with AutomaticKeepAliveClientMixin<ExpertHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expert Home"),
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> MessagesHome(userID: widget.userID,)));
            },
            title: Text("Messages"),
          ),
          ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=> AgrovetProducts()));
            },
            title: Text("View Aggrovet Products"),
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Home()));
            },
            title: Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
