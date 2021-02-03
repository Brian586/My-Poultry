import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_poultry/Authentication/login.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/DialogBox/errorDialog.dart';
import 'package:my_poultry/DialogBox/loadingDialog.dart';
import 'package:my_poultry/pages/home.dart';
import 'package:my_poultry/widgets/customTextField.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}



class _RegisterState extends State<Register>
{
  final TextEditingController _nameTextEditingController = TextEditingController();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final TextEditingController _cPasswordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl = "";
  File _imageFile;
  bool valuefirst = false;

  Future<void> _selectAndPickImage() async {
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> uploadAndSaveImage() async {
    if(_imageFile == null)
      {
        showDialog(
            context: context,
          builder: (c) {
              return ErrorAlertDialog(message: "Please select an image",);
          }
        );
      }
    else
      {
        _passwordTextEditingController.text
            == _cPasswordTextEditingController.text
            ? _emailTextEditingController.text.isNotEmpty
            && _passwordTextEditingController.text.isNotEmpty
            && _cPasswordTextEditingController.text.isNotEmpty
            && _nameTextEditingController.text.isNotEmpty

            ? uploadToStorage()
            : displayDialog("Write the required registration form")
            : displayDialog("Password does not match");
      }
  }

  uploadToStorage() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingAlertDialog(message: 'Registering, Please wait...',);
      }
    );

    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

    StorageReference storageReference = FirebaseStorage.instance.ref().child(imageFileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(_imageFile);

    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

    await taskSnapshot.ref.getDownloadURL().then((url) {
      userImageUrl = url;

      _registerUser();
    });
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void _registerUser() async{
    FirebaseUser firebaseUser;

    await _auth.createUserWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    ).then((auth) {
      firebaseUser = auth.user;
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
        saveUserToFireStore(firebaseUser).then((value) {
          Navigator.pop(context);
          Route route = MaterialPageRoute(builder: (context) => Home());
          Navigator.pushReplacement(context, route);
        });
      }
  }

  Future saveUserToFireStore(FirebaseUser fUser) async {
    Firestore.instance.collection("users").document(fUser.uid).setData({
      "uid": fUser.uid,
      "email": fUser.email,
      "name": _nameTextEditingController.text.trim(),
      "url": userImageUrl,
      MyPoultry.userCartList: ["garbageValue"]
    });

    await MyPoultry.sharedPreferences.setString("uid", fUser.uid);
    await MyPoultry.sharedPreferences.setString(MyPoultry.userEmail, fUser.email);
    await MyPoultry.sharedPreferences.setString(MyPoultry.userName, _nameTextEditingController.text);
    await MyPoultry.sharedPreferences.setString(MyPoultry.userAvatarUrl, userImageUrl);
    await MyPoultry.sharedPreferences.setStringList(MyPoultry.userCartList, ["garbageValue"]);
  }

  displayDialog(String msg)
  {
    showDialog(
      context: context,
      builder: (c) {
        return ErrorAlertDialog(message: msg,);
      }
    );
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
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 80.0,),
              Text("Sign Up", style: GoogleFonts.fredokaOne(fontSize: 18.0),),
              SizedBox(height: 20.0,),
              InkWell(
                onTap: _selectAndPickImage,
                child: CircleAvatar(
                  radius: _screenWidth * 0.15,
                  backgroundColor: Colors.white,
                  backgroundImage: _imageFile == null ? null : FileImage(_imageFile),
                  child: _imageFile == null
                      ? Container(
                    height: _screenWidth * 0.3,
                    width: _screenWidth * 0.3,
                    child: Center(child: Icon(Icons.person, size: 60.0,),),
                  ) : null,
                ),
              ),
              SizedBox(height: 8.0,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameTextEditingController,
                      data: Icons.person,
                      hintText: "Name",
                      isObscure: false,
                    ),
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
                    CustomTextField(
                      controller: _cPasswordTextEditingController,
                      data: Icons.lock_outline,
                      hintText: "Confirm Password",
                      isObscure: true,
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.pink,
                      value: this.valuefirst,
                      onChanged: (bool value) {
                        setState(() {
                          this.valuefirst = value;
                        });
                      },
                    ),
                    Text("I agree to the Terms of Service \nand Privacy Policy", maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17.0, color: Colors.grey),)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    onPressed: () { uploadAndSaveImage(); },
                    color: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                    child: Text("Continue", style: GoogleFonts.fredokaOne(color: Colors.white, fontSize: 17.0),),
                    elevation: 5.0,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Have an Account?", style: TextStyle(fontSize: 17.0, color: Colors.grey),),
                  FlatButton(
                      onPressed: () {
                        Route route = MaterialPageRoute(builder: (_) => Login());
                        Navigator.pushReplacement(context, route);
                      },
                      child: Text("Sign In", style: TextStyle(fontSize: 17.0, color: Colors.pink),))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

