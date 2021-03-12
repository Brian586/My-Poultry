import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChartData {
  final String x;
  final int y;
  final int y2;

  ChartData(this.x, this.y, this.y2);

  factory ChartData.fromDocument(DocumentSnapshot doc) {
    return ChartData(
        DateFormat("MMM dd, hh:mm").format(DateTime.fromMillisecondsSinceEpoch(doc["timestamp"])),
        doc["meat"],
        doc["eggs"]
    );
  }

}