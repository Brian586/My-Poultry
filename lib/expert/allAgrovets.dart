import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/expert/model/agrovetModel.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';

import '../widgets/customTextField.dart';
import 'model/agrovetModel.dart';


class AllAgrovets extends StatefulWidget {
  @override
  _AllAgrovetsState createState() => _AllAgrovetsState();
}

class _AllAgrovetsState extends State<AllAgrovets> {
  bool loading = false;
  Future futureFeedback;

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    Future future = Firestore.instance.collection('admins').getDocuments();

    setState(() {
      loading = false;
      futureFeedback = future;
    });
  }

  delete(String id) async {
    setState(() {
      loading = true;
    });

    await Firestore.instance.collection("admins").document(id).delete()
        .then((value) => Fluttertoast.showToast(msg: "Deleted Successfully"));

    setState(() {
      loading = false;
    });
  }

  display() {
    return FutureBuilder<QuerySnapshot>(
      future: futureFeedback,
      builder: (context, snap) {
        if(!snap.hasData)
        {
          return circularProgress();
        }
        else
        {
          List<Agrovet> feedbackList = [];
          snap.data.documents.forEach((element) {
            Agrovet agrovet = Agrovet.fromDocument(element);

            feedbackList.add(agrovet);
          });

          if(feedbackList.length == 0)
          {
            return Center(child: Text('No Feedback'),);
          }
          else
          {
            return ListView.builder(
              itemCount: feedbackList.length,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                Agrovet agrovet = feedbackList[index];

                return ListTile(
                  leading: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(agrovet.url),
                            fit: BoxFit.cover
                        ),
                        borderRadius: BorderRadius.circular(45.0),
                        border: Border.all(
                            color: Colors.pink,
                            width: 2.0
                        )
                    ),
                  ),
                  title: Text(agrovet.name.trimRight(), style: TextStyle(fontWeight: FontWeight.bold),),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text("Edit"),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> AgroEdit(agrovet: agrovet,)));
                        },
                      ),
                      TextButton(
                        child: Text("Delete"),
                        onPressed: () => delete(agrovet.id),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agrovets'),
      ),
      body: loading ? circularProgress() : display(),
    );
  }
}


class AgroEdit extends StatefulWidget {

  final Agrovet agrovet;

  AgroEdit({this.agrovet});

  @override
  _AgroEditState createState() => _AgroEditState();
}

class _AgroEditState extends State<AgroEdit> {

  bool loading = false;
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  @override
  void initState() {
    super.initState();

    name.text = widget.agrovet.name;
    phone.text = widget.agrovet.phone;
  }

  update() async {
    setState(() {
      loading = true;
    });

    await Firestore.instance.collection("admins").document(widget.agrovet.id).updateData({
      "name": name.text.trim(),
      "phone": phone.text.trim(),
    }).then((value) => Fluttertoast.showToast(msg: 'Updated successfully'));

    setState(() {
      loading= false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              controller: name,
              isObscure: false,
              data: Icons.person,
              hintText: 'Name',
            ),
            CustomTextField(
              controller: phone,
              isObscure: false,
              data: Icons.phone,
              hintText: 'Phone',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 40,
                  //width: 180,
                  child: RaisedButton(
                    onPressed: update,
                    color: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                      child: Text("Update", style: GoogleFonts.fredokaOne(color: Colors.white),),
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

