import 'package:cloud_firestore/cloud_firestore.dart';

class FeedBack {
  final String feedback;
  final String username;
  final String userID;
  final int timestamp;

  FeedBack({this.feedback, this.userID, this.timestamp, this.username});

  factory FeedBack.fromDocument(DocumentSnapshot doc) {
    return FeedBack(
      feedback: doc['feedback'],
      username: doc['username'],
      userID: doc['userID'],
      timestamp: doc['timestamp'],
    );
  }
}