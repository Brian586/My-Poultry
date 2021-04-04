import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/Address/addAddress.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';


class FeedBack extends StatefulWidget {
  @override
  _FeedBackState createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
  TextEditingController feedback = TextEditingController();
  bool loading = false;


  saveData() async {
    setState(() {
      loading = true;
    });

    await Firestore.instance.collection("feedback").add({
      "feedback": feedback.text,
      "username": MyPoultry.sharedPreferences.getString(MyPoultry.userName),
      "userID": MyPoultry.sharedPreferences.getString(MyPoultry.userUID),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    }).then((value) => Fluttertoast.showToast(msg: "Uploaded Successfully"));

    setState(() {
      loading = false;
      feedback.clear();
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produce Data"),
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            MyTextField(
              controller: feedback,
              hint: 'feedback',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 40,
                  //width: 180,
                  child: RaisedButton(
                    onPressed: saveData,
                    color: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: Text("Submit", style: GoogleFonts.fredokaOne(color: Colors.white),),
                    elevation: 5.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
