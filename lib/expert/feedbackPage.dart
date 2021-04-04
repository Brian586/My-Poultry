import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/expert/model/feedbackModel.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';


class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {

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

    Future future = Firestore.instance.collection('feedback').getDocuments();

    setState(() {
      loading = false;
       futureFeedback = future;
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
            List<FeedBack> feedbackList = [];
            snap.data.documents.forEach((element) {
              FeedBack feedBack = FeedBack.fromDocument(element);

              feedbackList.add(feedBack);
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
                    FeedBack feedBack = feedbackList[index];

                    return ListTile(
                      title: Text(feedBack.username, style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text(feedBack.feedback, maxLines: 4,),
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
        title: Text('Feedback'),
      ),
      body: loading ? circularProgress() : display(),
    );
  }
}
