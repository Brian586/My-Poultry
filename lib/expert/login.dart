import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_poultry/DialogBox/errorDialog.dart';
import 'package:my_poultry/expert/expertHome.dart';
import 'package:my_poultry/widgets/customTextField.dart';

class ExpertLogin extends StatefulWidget {
  @override
  _ExpertLoginState createState() => _ExpertLoginState();
}

class _ExpertLoginState extends State<ExpertLogin> {
  final TextEditingController _adminIDTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  loginAdmin() {
    Firestore.instance.collection("experts").document(_adminIDTextEditingController.text.trim()).get().then((res) {

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

        Route route = MaterialPageRoute(builder: (context)=> ExpertHome(
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


    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body:  SingleChildScrollView(
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
                child: Text("Expert Login", style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),),
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
            ],
          ),
        ),
      ),
    );
  }
}
