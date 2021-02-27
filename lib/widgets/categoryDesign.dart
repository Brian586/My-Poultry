import 'package:flutter/material.dart';
import 'package:my_poultry/models/category.dart';

class CategoryDesign extends StatelessWidget {

  final Category category;
  final Function onTap;
  final int id;

  CategoryDesign({this.category, this.onTap, this.id});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 90.0,
              width: 90.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(category.imageUrl),
                  fit: BoxFit.cover
                ),
                borderRadius: BorderRadius.circular(45.0),
                border: Border.all(
                  color: Colors.pink.withOpacity(0.4),
                  width: 5.0
                )
              ),
            ),
            SizedBox(height: 10.0,),
            Text(category.title, style: TextStyle(fontWeight: FontWeight.bold, color: id == category.id ? Colors.pink : Colors.black),)
          ],
        ),
      ),
    );
  }
}
