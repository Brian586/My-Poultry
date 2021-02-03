import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/Authentication/register.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/DialogBox/errorDialog.dart';
import 'package:my_poultry/DialogBox/loadingDialog.dart';
import 'package:my_poultry/pages/home.dart';
import 'package:my_poultry/widgets/customTextField.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}





class _LoginState extends State<Login>
{
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;

  void loginUser() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingAlertDialog(message: "Authenticating. Please wait...",);
      }
    );
    FirebaseUser firebaseUser;

    await _auth.signInWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    ).then((authUser) {
      firebaseUser = authUser.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(message: error.message.toString(),);
          }
      );
    });

    if(firebaseUser != null)
      {
        readData(firebaseUser).then((s) {
          Navigator.pop(context);
          Route route = MaterialPageRoute(builder: (context)=> Home());
          Navigator.pushReplacement(context, route);
        });
      }
  }

  Future readData(FirebaseUser fUser) async {
    Firestore.instance.collection("users").document(fUser.uid).get().then((dataSnapshot) async {
      await MyPoultry.sharedPreferences.setString("uid", dataSnapshot.data[MyPoultry.userUID]);

      await MyPoultry.sharedPreferences.setString(MyPoultry.userEmail, dataSnapshot.data[MyPoultry.userEmail]);

      await MyPoultry.sharedPreferences.setString(MyPoultry.userName, dataSnapshot.data[MyPoultry.userName]);

      await MyPoultry.sharedPreferences.setString(MyPoultry.userAvatarUrl, dataSnapshot.data[MyPoultry.userAvatarUrl]);

      List<String> cartList = dataSnapshot.data[MyPoultry.userCartList].cast<String>();
      await MyPoultry.sharedPreferences.setStringList(MyPoultry.userCartList, cartList);
    });
  }

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 100.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sign In", style: GoogleFonts.fredokaOne(fontSize: 18.0),),
                    Text("Hi there!", style: TextStyle(color: Colors.grey, fontSize: 16.0),)
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailTextEditingController,
                      data: Icons.email,
                      hintText: "Email",
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    onPressed: () {
                      _emailTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty
                          ? loginUser()
                          : showDialog(
                          context: context,
                          builder: (c) {
                            return ErrorAlertDialog(message: "Please write email and password",);
                          }
                      );
                    },
                    color: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                    child: Text("Sign In", style: GoogleFonts.fredokaOne(color: Colors.white, fontSize: 17.0),),
                    elevation: 5.0,
                  ),
                ),
              ),
              SizedBox(height: 30.0,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Forgot Password?", style: TextStyle(fontSize: 17.0, color: Colors.grey),),
                    FlatButton(
                        onPressed: () {
                          Route route = MaterialPageRoute(builder: (_) => Register());
                          Navigator.pushReplacement(context, route);
                        },
                        child: Text("Sign Up", style: TextStyle(fontSize: 17.0, color: Colors.pink),))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
