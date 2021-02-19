import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


class CustomIndicator extends StatelessWidget {

  final double percent;
  final String amount;
  final String category;
  final Color color;

  CustomIndicator({this.color, this.amount, this.category, this.percent});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: MediaQuery.of(context).size.width * 0.25,
      lineWidth: 7.0,
      animation: true,
      percent: percent,
      center: new Text(
        amount,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      header: Text(
        category,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0, color: Colors.grey),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: color,
    );
  }
}
