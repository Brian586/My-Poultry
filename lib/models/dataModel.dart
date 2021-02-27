import 'package:cloud_firestore/cloud_firestore.dart';

class PoultryData {
  final String name;
  final int males;
  final int females;
  final int chicks;
  final int timestamp;

  PoultryData({this.timestamp, this.name, this.chicks, this.females, this.males});

  factory PoultryData.fromDocument(DocumentSnapshot doc)
  {
    return PoultryData(
      name: doc["name"],
      males: doc["males"],
      females: doc["females"],
      chicks: doc["chicks"],
      timestamp: doc["timestamp"]
    );
  }

}