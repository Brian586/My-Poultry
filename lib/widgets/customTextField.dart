import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget
{
  final TextEditingController controller;
  final IconData data;
  final String hintText;
  bool isObscure = true;



  CustomTextField(
      {Key key, this.controller, this.data, this.hintText,this.isObscure}
      ) : super(key: key);



  @override
  Widget build(BuildContext context)
  {
    return Container
    (
      decoration: BoxDecoration(
        // color: Colors.grey.withOpacity(0.3),
        // borderRadius: BorderRadius.circular(30.0),
      ),
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              width: 1.0,
            )
          ),
          prefixIcon: Icon(data, color: Colors.grey[400],),
          focusColor: Theme.of(context).primaryColor,
          hintText: hintText,
          labelText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
