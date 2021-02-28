import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:my_poultry/models/groupModel.dart';
import 'package:my_poultry/pages/home.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupInfo extends StatelessWidget {

  final MyGroup group;

  const GroupInfo({Key key, this.group, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(group.name, style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),),
          SizedBox(height: 10.0,),
          Linkify(
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
            text: "Link: ${group.link}",
            linkStyle: TextStyle(color: Colors.pinkAccent),
          )
        ],
      ),
      actions: [
        RaisedButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)
            ),
            color: Colors.pink,
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Home()));
            },
            elevation: 5.0,
            icon: Icon(Icons.done, color: Colors.white,),
            label: Text("Done", style: TextStyle(color: Colors.white),)
        )
      ],
    );
  }
}
