import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_poultry/Admin/uploadItems.dart';
import 'package:my_poultry/DialogBox/errorDialog.dart';
import 'package:my_poultry/widgets/customTextField.dart';

import 'adminRegister.dart';




class AdminSignInPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin",
          style: TextStyle(
              color: Colors.white,
              //fontSize: 40.0,
              //fontFamily: "Signatra"
          ),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}


class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen>
{
  final TextEditingController _adminIDTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  loginAdmin() {
    Firestore.instance.collection("admins").document(_adminIDTextEditingController.text.trim()).get().then((res) {

        if(res.data["id"] != _adminIDTextEditingController.text.trim())
        {
          Fluttertoast.showToast(
            msg: "Your ID is not correct",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black.withOpacity(0.4),
            textColor: Colors.white,
            fontSize: 16.0
          );
        }
        else if(res.data["password"] != _passwordTextEditingController.text.trim())
          {
            Fluttertoast.showToast(
                msg: "Your password is not correct",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black.withOpacity(0.4),
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
        else
          {
            Fluttertoast.showToast(
                msg: "Welcome " + res.data["name"],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black.withOpacity(0.4),
                textColor: Colors.white,
                fontSize: 16.0
            );

            setState(() {
              _adminIDTextEditingController.text = "";
              _passwordTextEditingController.text = "";
            });

            Route route = MaterialPageRoute(builder: (context)=> UploadPage(
              name: res.data["name"],
              phone: res.data["phone"],
              userID: res.documentID,
            ));
            Navigator.pushReplacement(context, route);
          }
    });
  }

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset("assets/admin.png", height: 240.0, width: 240.0,),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Agrovet Login", style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _adminIDTextEditingController,
                    data: Icons.person,
                    hintText: "National ID",
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.lock_outlined,
                    hintText: "Password",
                    isObscure: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              onPressed: () {
                _adminIDTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(
                    context: context,
                    builder: (c) {
                      return ErrorAlertDialog(message: "Please write ID and password",);
                    }
                );
              },
              color: Colors.pink,
              child: Text("Login", style: TextStyle(color: Colors.white),),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.pink,
            ),
            SizedBox(
              height: 20.0,
            ),
            Text("Don't have an Admin Account?"),
            FlatButton.icon(
                onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminRegisterPage())),
                icon: Icon(Icons.admin_panel_settings_outlined, color: Colors.pink,),
                label: Text("Become an Admin", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),)
            )
          ],
        ),
      ),
    );
  }
}
