import 'package:cloud_firestore/cloud_firestore.dart';

class Agrovet {
  final String id;
  final String name;
  final String phone;
  final String url;

  Agrovet({this.id, this.name, this.phone, this.url});

  factory Agrovet.fromDocument(DocumentSnapshot doc) {
    return Agrovet(
      id: doc['id'],
      name: doc['name'],
      phone: doc['phone'],
      url: doc['url'],
    );
  }
}