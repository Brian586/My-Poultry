import 'package:flutter/material.dart';
import 'package:my_poultry/models/dataModel.dart';


class PoultryDataLayout extends StatelessWidget {

  final PoultryData poultryData;

  PoultryDataLayout({this.poultryData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ListTile(
        title: Text(poultryData.name, style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text(
          "Total: " + (poultryData.males + poultryData.females + poultryData.chicks).toString()
        ),
      ),
    );
  }
}
