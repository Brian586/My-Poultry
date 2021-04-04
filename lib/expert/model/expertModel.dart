import 'package:cloud_firestore/cloud_firestore.dart';

class Expert {
  final String name;
  final String id;
  final String phone;
  final String photo;
  final String cvUrl;
  final String certUrl;

  Expert({this.certUrl, this.cvUrl, this.photo, this.id, this.name, this.phone});

  factory Expert.fromDocument(DocumentSnapshot doc) {
    return Expert(
      name: doc["name"],
      id: doc["id"],
      phone: doc["phone"],
      photo: doc["url"],
      cvUrl: doc["cv"],
      certUrl: doc["cert"],
    );
  }
}