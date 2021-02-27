import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/models/messageModel.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';

class ChatDetails extends StatefulWidget {

  final String userId;

  ChatDetails({this.userId});

  @override
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {

  final TextEditingController messageTextEditingController = TextEditingController();
  MessageDBManager messageDBManager = MessageDBManager();
  bool loading = false;
  String profilePhoto;
  String name;
  bool sending = false;
  Future futureMessageResult;
  
  @override
  void initState() {
    super.initState();

    loadMessages();
    getUserInfo();
  }

  loadMessages() async {//TODO ChatID is current userID + receiverID
    setState(() {
      loading = true;
    });

    int timestamp = await messageDBManager.getTimestamp((MyPoultry.sharedPreferences.getString(MyPoultry.userUID))+widget.userId);

    await Firestore.instance.collection("users")
        .document(MyPoultry.sharedPreferences.getString(MyPoultry.userUID))
        .collection("messages").where("timestamp", isGreaterThan: timestamp)
        .where("chatID", isEqualTo: (MyPoultry.sharedPreferences.getString(MyPoultry.userUID))+widget.userId)
        .orderBy("timestamp", descending: true).getDocuments().then((querySnapshot) {
          querySnapshot.documents.forEach((document) async {
            MyMessage message = MyMessage.fromDocument(document);

            await messageDBManager.saveMessage(message);

          });
    });

    await setIsSeenTrue();

    futureMessageResult = messageDBManager.loadMessages((MyPoultry.sharedPreferences.getString(MyPoultry.userUID))+widget.userId);


    setState(() {
      loading = false;
    });
  }

  setIsSeenTrue() async {
    await messageDBManager.updateField((MyPoultry.sharedPreferences.getString(MyPoultry.userUID))+widget.userId);

  }

  getUserInfo() async {
    setState(() {
      loading = true;
    });
    
    await Firestore.instance.collection("admins").document(widget.userId).get().then((value) {
      setState(() {
        name = value.data["name"];
        profilePhoto = value.data["url"];
      });
    });
    
    setState(() {
      loading = false;
    });
  }

  sendMessage() async {
    setState(() {
      sending = true;
    });

    if(messageTextEditingController.text.isNotEmpty)
      {
        await Firestore.instance.collection("admins").document(widget.userId).collection("messages").add({
          "message": messageTextEditingController.text,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "senderID":  MyPoultry.sharedPreferences.getString(MyPoultry.userUID),
          "chatID": (MyPoultry.sharedPreferences.getString(MyPoultry.userUID))+widget.userId,
          "isSeen": "false",
          "photoUrl": MyPoultry.sharedPreferences.getString(MyPoultry.userAvatarUrl),
          "receiverPhotoUrl": profilePhoto,
          "senderName": MyPoultry.sharedPreferences.getString(MyPoultry.userName),
          "receiverID": widget.userId,
          "receiverName": name,
        });

        MyMessage message = MyMessage(
          message: messageTextEditingController.text,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          senderID:  MyPoultry.sharedPreferences.getString(MyPoultry.userUID),
          chatID: (MyPoultry.sharedPreferences.getString(MyPoultry.userUID))+widget.userId,
          isSeen: "true",
          photoUrl: MyPoultry.sharedPreferences.getString(MyPoultry.userAvatarUrl),
          senderName: MyPoultry.sharedPreferences.getString(MyPoultry.userName),
          receiverID: widget.userId,
          receiverPhotoUrl: profilePhoto,
          receiverName: name,
        );

        await messageDBManager.saveMessage(message);

        await loadMessages();

        Fluttertoast.showToast(msg: "Message Sent Successfully");
      }
    else
      {
        Fluttertoast.showToast(msg: "Blank message");
      }

    setState(() {
      messageTextEditingController.clear();
      sending = false;
    });
  }

  String displayTime(int timestamp) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat format = DateFormat("HH:mm");

    return format.format(time);
  }

  displayMessages() {
    return FutureBuilder(
      future: futureMessageResult,
      builder: (context, snapshot) {
        if(!snapshot.hasData)
          {
            return circularProgress();
          }
        else
          {
            List<MyMessage> messages = snapshot.data;

            if(messages.length == 0)
              {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_emotions_rounded, color: Colors.grey, size: 30.0,),
                      SizedBox(height: 10.0,),
                      Text("Start chatting", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),)
                    ],
                  ),
                );
              }
            else
              {
                return ListView.builder(
                  itemCount: messages.length,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    MyMessage message = messages[index];
                    bool isMyText = message.senderID == MyPoultry.sharedPreferences.getString(MyPoultry.userUID);

                    return Column(
                      children: [
                        Padding(
                          padding: isMyText
                              ? EdgeInsets.only(right: 20.0, top: 10.0, bottom: 10.0, left: MediaQuery.of(context).size.width * 0.25)
                              : EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0, right: MediaQuery.of(context).size.width * 0.25),
                          child: Align(
                            alignment: isMyText ? Alignment.centerRight: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                  color:isMyText ? Colors.white : Colors.grey,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(2.0, 2.0),
                                        spreadRadius: 1.0,
                                        blurRadius: 12.0
                                    )
                                  ],
                                  borderRadius: BorderRadius.only(
                                    topLeft: isMyText ? Radius.circular(15.0) : Radius.circular(2.0),
                                    topRight: isMyText ? Radius.circular(2.0) : Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0),
                                    bottomLeft: Radius.circular(15.0),
                                  )
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(message.message, style: TextStyle(color:isMyText ? Colors.grey : Colors.white, fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        ),
                        //SizedBox(height: 5.0,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Align(
                            alignment: isMyText ? Alignment.centerRight : Alignment.centerLeft,
                              child: Text(displayTime(message.timestamp), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0),)),
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

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {

        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }

    return time;
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: loading ? Text("") : Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(profilePhoto),
            ),
            SizedBox(width: 10.0,),
            Text(name, style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),)
          ],
        ),
      ),
      body: loading ? circularProgress() : Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            color: Colors.grey.withOpacity(0.3),
            child: displayMessages(),
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    //height: 60.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: Center(
                      child: TextFormField(
                        maxLines: null,
                        controller: messageTextEditingController,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                width: 1.0,
                              )
                          ),
                          prefixIcon: Icon(Icons.text_format_rounded, color: Colors.grey[400],),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400],),
                            onPressed: () {
                              messageTextEditingController.clear();
                            },
                          ),
                          focusColor: Theme.of(context).primaryColor,
                          hintText: "Type here...",
                          //labelText: hintText,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    child: RaisedButton(
                      onPressed: sendMessage,
                      color: Colors.pink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)
                      ),
                      elevation: 5.0,
                      child: Icon(Icons.send_rounded, color: Colors.white,),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
