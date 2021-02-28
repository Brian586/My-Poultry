import 'package:cloud_firestore/cloud_firestore.dart';

class MyGroup {
  final String name;
  final String type;
  final String link;
  final int timestamp;
  final List<dynamic> members;

  MyGroup({this.name, this.link, this.type, this.timestamp, this.members});

  factory MyGroup.fromDocument(DocumentSnapshot doc) {
    return MyGroup(
      name: doc["name"],
      type: doc["type"],
      link: doc["link"],
      timestamp: doc["timestamp"],
      members: doc["members"],
    );
  }
}