import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/expert/feedback.dart';
import 'package:my_poultry/expert/login.dart';
import 'package:my_poultry/expert/model/expertModel.dart';
import 'package:my_poultry/expert/sendSms.dart';
import 'package:my_poultry/expert/signUp.dart';
import 'package:my_poultry/expert/superAdmin.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';
import 'package:url_launcher/url_launcher.dart';


class ExpertsPage extends StatefulWidget {
  @override
  _ExpertsPageState createState() => _ExpertsPageState();
}

class _ExpertsPageState extends State<ExpertsPage> {

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
                          IconButton(
                            icon: Icon(Icons.call, color: Colors.pink,),
                            onPressed: () => launch("tel:${expert.phone}"),
                          ),
                          IconButton(
                            icon: Icon(Icons.message_outlined, color: Colors.pink,),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> SendMessage(userId: expert.id,)));
                            },
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
        title: Text("Experts"),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.admin_panel_settings_outlined, color: Colors.white,),
            label: Text("Admin", style: TextStyle(color: Colors.white),),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> SuperAdmin()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            displayExperts(),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> FeedBack()));
              },
              child: Text("Send Feedback"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ExpertSignUp()));
              },
              child: Text("Sign Up as Expert"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ExpertLogin()));
              },
              child: Text("Expert Login"),
            )
          ],
        ),
      ),
    );
  }
}
