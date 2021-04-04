import 'package:flutter/material.dart';
import 'package:my_poultry/expert/allAgrovets.dart';
import 'package:my_poultry/expert/allExperts.dart';
import 'package:my_poultry/expert/feedbackPage.dart';


class SuperAdmin extends StatefulWidget {
  @override
  _SuperAdminState createState() => _SuperAdminState();
}

class _SuperAdminState extends State<SuperAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Super Admin"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> AllExperts()));
              },
              title: Text("Experts"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> AllAgrovets()));
              },
              title: Text("Agrovets"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> FeedbackPage()));
              },
              title: Text("Feedback"),
            ),
          ],
        ),
      ),
    );
  }
}
