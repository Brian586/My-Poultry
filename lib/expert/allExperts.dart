
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';

import '../widgets/customTextField.dart';
import 'model/expertModel.dart';
import 'model/expertModel.dart';


class AllExperts extends StatefulWidget {
  @override
  _AllExpertsState createState() => _AllExpertsState();
}

class _AllExpertsState extends State<AllExperts> {

  bool loading = false;
  Future futureExperts;

  @override
  void initState() {
    super.initState();

    getExpertList();
  }

  getExpertList() async {
    setState(() {
      loading = true;
    });

    Future experts = Firestore.instance.collection("experts").getDocuments();

    setState(() {
      loading = false;
      futureExperts = experts;
    });
  }

  delete(String id) async {
    setState(() {
      loading = true;
    });
    
    await Firestore.instance.collection("experts").document(id).delete()
        .then((value) => Fluttertoast.showToast(msg: "Deleted Successfully"));
    
    setState(() {
      loading = false;
    });
  }

  displayExperts() {
    return FutureBuilder<QuerySnapshot>(
      future: futureExperts,
      builder: (context, snapshot) {
        if(!snapshot.hasData)
        {
          return circularProgress();
        }
        else
        {
          List<Expert> experts = [];
          snapshot.data.documents.forEach((element) {
            Expert expert = Expert.fromDocument(element);
            experts.add(expert);
          });

          if(experts.length == 0)
          {
            return Center(child: Text("No available Experts"),);
          }
          else
          {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: experts.length,
              itemBuilder: (BuildContext context, int index) {
                Expert expert = experts[index];

                return ListTile(
                  leading: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(expert.photo),
                            fit: BoxFit.cover
                        ),
                        borderRadius: BorderRadius.circular(45.0),
                        border: Border.all(
                            color: Colors.pink,
                            width: 2.0
                        )
                    ),
                  ),
                  title: Text(expert.name.trimRight(), style: TextStyle(fontWeight: FontWeight.bold),),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text("Edit"),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> ExpertEdit(expert: expert,)));
                        },
                      ),
                      TextButton(
                        child: Text("Delete"),
                        onPressed: () => delete(expert.id),
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
        title: Text("Expert List"),
      ),
      body: ListView(
        children: [
          displayExperts()
        ],
      ),
    );
  }
}

class ExpertEdit extends StatefulWidget {

  final Expert expert;

  ExpertEdit({this.expert});

  @override
  _ExpertEditState createState() => _ExpertEditState();
}

class _ExpertEditState extends State<ExpertEdit> {
  bool loading = false;
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  @override
  void initState() {
    super.initState();

    name.text = widget.expert.name;
    phone.text = widget.expert.phone;
  }

  update() async {
    setState(() {
      loading = true;
    });

    await Firestore.instance.collection("experts").document(widget.expert.id).updateData({
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

