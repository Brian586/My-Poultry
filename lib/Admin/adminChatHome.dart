import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_poultry/models/messageModel.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';

import 'adminChatDetails.dart';


class AdminChatHome extends StatefulWidget {

  final String userID;

  AdminChatHome({this.userID});

  @override
  _AdminChatHomeState createState() => _AdminChatHomeState();
}

class _AdminChatHomeState extends State<AdminChatHome> {

  final AdminMessageDBManager messageDBManager = AdminMessageDBManager();
  bool loading = false;
  Future futureMessages;

  @override
  void initState() {
    super.initState();

    getMessages();
  }

  Future<void> getMessages() async {
    setState(() {
      loading= true;
    });

    int timestamp = await messageDBManager.getLastMessage();

    await Firestore.instance.collection("admins")
        .document(widget.userID)
        .collection("messages").where("timestamp", isGreaterThan: timestamp)
        .orderBy("timestamp", descending: true).getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((document) async {
        MyMessage message = MyMessage.fromDocument(document);

        await messageDBManager.saveMessage(message);
        //print(message);
      });
    });

    futureMessages = messageDBManager.loadChatHomeMessages();

    setState(() {
      loading = false;
    });
  }

  String displayTime(int timestamp) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat format = DateFormat("HH:mm");

    return format.format(time);
  }

  showMessageList() {
    return FutureBuilder(
      future: futureMessages,
      builder: (context, snap) {
        if(!snap.hasData)
        {
          return circularProgress();
        }
        else
        {
          List<MyMessage> messageList = snap.data;

          if(messageList.length == 0)
          {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_emotions_rounded, color: Colors.grey, size: 30.0,),
                  SizedBox(height: 10.0,),
                  Text("No Messages", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),)
                ],
              ),
            );
          }
          else
          {
            return ListView.builder(
              itemCount: messageList.length,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                MyMessage message = messageList[index];
                bool isSeen = message.isSeen == "true";
                bool isMe = message.senderID == widget.userID;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      onTap: () {
                        Route route = MaterialPageRoute(builder: (context)=> AdminChatDetails(message: message,));
                        Navigator.push(context, route);
                      },
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(message.photoUrl),
                        radius: 30.0,
                      ),
                      title: Text(message.senderName.trimRight(), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.fredokaOne(color: Colors.black, fontSize: 17.0),),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(isMe ? "You: ${message.message.trimRight()}" :
                        message.message.trimRight(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15.0, color: Colors.grey, fontWeight: isSeen ? FontWeight.normal : FontWeight.bold,),),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(displayTime(message.timestamp), style: TextStyle(fontWeight: FontWeight.w700),),
                          isSeen ? Text("") : Icon(Icons.circle, color: Colors.green, size: 25.0,)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 20.0, left: 80.0),
                      child: Divider(),
                    )
                  ],
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white,),
            onPressed: () {},
          ),
          // IconButton(
          //   icon: Icon(Icons.refresh_rounded, color: Colors.white,),
          //   onPressed: getMessages,
          // )
        ],
        title: Text("Messages"),
      ),
      body: RefreshIndicator(
        child:  showMessageList(),
        onRefresh: getMessages,
      ),
    );
  }
}
