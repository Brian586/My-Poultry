import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_poultry/DialogBox/errorDialog.dart';
import 'package:my_poultry/DialogBox/loadingDialog.dart';
import 'package:my_poultry/expert/expertHome.dart';
import 'package:my_poultry/widgets/customTextField.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';
import 'package:path/path.dart';


class ExpertSignUp extends StatefulWidget {
  @override
  _ExpertSignUpState createState() => _ExpertSignUpState();
}

class _ExpertSignUpState extends State<ExpertSignUp> {
  final TextEditingController _adminIDTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final TextEditingController _confirmPasswordTextEditingController = TextEditingController();
  final TextEditingController _nameTextEditingController = TextEditingController();
  final TextEditingController _phoneTextEditingController = TextEditingController();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;
  String userImageUrl = "";
  File _imageFile;
  File cv;
  File certificate;
  String cvUrl = "";
  String certUrl = "";


  registerAdmin(BuildContext context) {
    if(_adminIDTextEditingController.text.isNotEmpty
        && _nameTextEditingController.text.isNotEmpty
        && _phoneTextEditingController.text.isNotEmpty
        && _imageFile != null && cv != null && certificate != null
        && _emailTextEditingController.text.isNotEmpty
        && _passwordTextEditingController.text.isNotEmpty
        && _confirmPasswordTextEditingController.text.isNotEmpty)
    {
      if(_confirmPasswordTextEditingController.text != _passwordTextEditingController.text)
      {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorAlertDialog(message: "Password does not match");
            }
        );
      }
      else
      {
        uploadPhoto(context);
      }
    }
    else
    {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(message: "Fill in the required fields",);
          }
      );
    }
  }

  uploadCv() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    StorageReference storageReference = FirebaseStorage.instance.ref().child(fileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(cv);

    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

    await taskSnapshot.ref.getDownloadURL().then((value) {
      setState(() {
        cvUrl = value;
      });
    });
  }

  uploadCert() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    StorageReference storageReference = FirebaseStorage.instance.ref().child(fileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(certificate);

    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

    await taskSnapshot.ref.getDownloadURL().then((value) {
      setState(() {
        certUrl = value;
      });
    });
  }

  uploadPhoto(BuildContext context) async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingAlertDialog(message: 'Registering, Please wait...',);
        }
    );

    await uploadCv();

    await uploadCert();

    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

    StorageReference storageReference = FirebaseStorage.instance.ref().child(imageFileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(_imageFile);

    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

    await taskSnapshot.ref.getDownloadURL().then((url) {
      userImageUrl = url;

      saveInfoToDB(context);
    });
  }

  saveInfoToDB(BuildContext context) async {
    await Firestore.instance.collection("experts").document(_adminIDTextEditingController.text.trim()).setData(
        {
          "name": _nameTextEditingController.text.trim(),
          "id": _adminIDTextEditingController.text.trim(),
          "phone": _phoneTextEditingController.text.trim(),
          "password": _passwordTextEditingController.text.trim(),
          "url": userImageUrl,
          "cv": cvUrl,
          "cert": certUrl,
          "paid": 0,
        }).then((value) {
      Fluttertoast.showToast(msg: "Registration Successful");
    });

    Route route = MaterialPageRoute(builder: (context)=> ExpertHome(
      name: _nameTextEditingController.text.trim(),
      phone: _phoneTextEditingController.text.trim(),
      userID: _adminIDTextEditingController.text.trim(),
    ));
    Navigator.pushReplacement(context, route);

  }

  Future<void> _selectAndPickImage() async {
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> getDoc1() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if(result != null) {
      setState(() {
        cv = File(result.files.single.path);
      });
    } else {
      // User canceled the picker
    }

  }

  Future<void> getDoc2() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if(result != null) {
      setState(() {
        certificate = File(result.files.single.path);
      });
    } else {
      // User canceled the picker
    }

  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Expert Sign Up",
          style: TextStyle(
            color: Colors.white,
            // fontSize: 40.0,
            // fontFamily: "Signatra"
          ),
        ),
        centerTitle: true,
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 10.0,),
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_screenWidth * 0.15),
                        image: DecorationImage(
                            image: AssetImage("assets/profile.png"),
                            fit: BoxFit.cover
                        )
                    ),
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
                      hintText: "Expert Name",
                      isObscure: false,
                    ),
                    CustomTextField(
                      controller: _emailTextEditingController,
                      data: Icons.email_outlined,
                      hintText: "Email",
                      isObscure: false,
                    ),
                    CustomTextField(
                      controller: _phoneTextEditingController,
                      data: Icons.phone_android,
                      hintText: "Phone Number",
                      isObscure: false,
                    ),
                    CustomTextField(
                      controller: _adminIDTextEditingController,
                      data: Icons.person,
                      hintText: "National ID",
                      isObscure: false,
                    ),
                    Text("Documents", style: TextStyle(fontWeight: FontWeight.bold),),
                    cv == null ? TextButton(
                      onPressed: getDoc1,
                      child: Text("Your CV",),
                    ) : Container(
                      height: 40.0,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(cv.path.split("/").last, style: TextStyle(color: Colors.pink),),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                          color: Colors.pink,
                          width: 1.0
                        )
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    certificate == null ? TextButton(
                      onPressed: getDoc2,
                      child: Text("Certificate",),
                    ) : Container(
                      height: 40.0,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(certificate.path.split("/").last, style: TextStyle(color: Colors.pink),),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                              color: Colors.pink,
                              width: 1.0
                          )
                      ),
                    ),
                    CustomTextField(
                      controller: _passwordTextEditingController,
                      data: Icons.lock_outlined,
                      hintText: "Password",
                      isObscure: true,
                    ),
                    CustomTextField(
                      controller: _confirmPasswordTextEditingController,
                      data: Icons.lock_outlined,
                      hintText: "Confirm Password",
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
                  registerAdmin(context);
                },
                color: Colors.pink,
                child: Text("Sign Up", style: TextStyle(color: Colors.white),),
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
