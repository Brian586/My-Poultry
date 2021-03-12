
import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccination {
  final String disease;
  final String vaccineName;
  final String type;
  final int dateTime;
  final String personnel;
  final int number;
  final String notes;

  Vaccination({
    this.dateTime,
    this.number,
    this.notes,
    this.disease,
    this.type,
    this.personnel, this.vaccineName,
});

  factory Vaccination.fromDocument(DocumentSnapshot doc) {
    return Vaccination(
      disease: doc["disease"],
      vaccineName: doc["vaccineName"],
      type: doc["type"],
      dateTime: doc["dateTime"],
      personnel: doc["vaccinatedBy"],
      number: doc["number"],
      notes: doc["notes"]
    );
  }

}

class Medication {
  final String disease;
  final String medicineName;
  final String type;
  final int dateTime;
  final String personnel;
  final int number;
  final String notes;

  Medication({
    this.dateTime,
    this.number,
    this.notes,
    this.disease,
    this.type,
    this.personnel, this.medicineName,
  });

  factory Medication.fromDocument(DocumentSnapshot doc) {
    return Medication(
        disease: doc["disease"],
        medicineName: doc["medicineName"],
        type: doc["type"],
        dateTime: doc["dateTime"],
        personnel: doc["medicatedBy"],
        number: doc["number"],
        notes: doc["notes"]
    );
  }
}