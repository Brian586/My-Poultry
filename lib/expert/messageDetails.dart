import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:my_poultry/models/messageModel.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';


class MessageDetails extends StatefulWidget {

  final MyMessage message;

  MessageDetails({this.message});


  @override
  _MessageDetailsState createState() => _MessageDetailsState();
}

class _MessageDetailsState extends State<MessageDetails> {
  final TextEditingController messageTextEditingController = TextEditingController();
  final AdminMessageDBManager messageDBManager = AdminMessageDBManager();
  bool loading = false;
  bool sending = false;
  Future futureMessageResult;

  @override
  void initState() {
    super.initState();

    loadMessages();
  }

  loadMessages() async {//TODO ChatID is current userID + receiverID
    setState(() {
      loading = true;
    });

    int timestamp = await messageDBManager.getTimestamp(widget.message.senderID+widget.message.receiverID);

    await Firestore.instance.collection("experts")
        .document(widget.message.receiverID)
        .collection("messages").where("timestamp", isGreaterThan: timestamp)
        .where("chatID", isEqualTo: (widget.message.senderID+widget.message.receiverID))
        .orderBy("timestamp", descending: true).getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((document) async {
        MyMessage message = MyMessage.fromDocument(document);

        await messageDBManager.saveMessage(message);

      });
    });

    await setIsSeenTrue();

    futureMessageResult = messageDBManager.loadMessages(widget.message.senderID+widget.message.receiverID);


    setState(() {
      loading = false;
    });
  }

  setIsSeenTrue() async {
    await messageDBManager.updateField(widget.message.senderID+widget.message.receiverID);

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
                bool isMyText = message.senderID == widget.message.receiverID;

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
                              color: isMyText ? Colors.white : Colors.grey,
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
                            child: Text(message.message, style: TextStyle(color: isMyText ? Colors.grey : Colors.white, fontWeight: FontWeight.bold),),
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


  sendMessage() async {
    setState(() {
      sending = true;
    });

    if(messageTextEditingController.text.isNotEmpty)
    {
      await Firestore.instance.collection("users").document(widget.message.senderID).collection("messages").add({
        "message": messageTextEditingController.text,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "senderID": widget.message.receiverID,
        "chatID": widget.message.senderID+widget.message.receiverID,
        "isSeen": "false",
        "photoUrl": widget.message.photoUrl,
        "receiverPhotoUrl": widget.message.receiverPhotoUrl,
        "senderName": widget.message.senderName,
        "receiverID": widget.message.senderID,
        "receiverName": widget.message.receiverName,
      });

      MyMessage message = MyMessage(
        message: messageTextEditingController.text,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        senderID:  widget.message.receiverID,
        chatID: widget.message.senderID+widget.message.receiverID,
        isSeen: "true",
        photoUrl: widget.message.photoUrl,
        senderName: widget.message.senderName,
        receiverID: widget.message.senderID,
        receiverPhotoUrl: widget.message.receiverPhotoUrl,
        receiverName: widget.message.receiverName,
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
              backgroundImage: NetworkImage(widget.message.photoUrl),
            ),
            SizedBox(width: 10.0,),
            Text(widget.message.senderName, style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),)
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
