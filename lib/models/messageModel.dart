import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class MyMessage {
  final String message;
  final int timestamp;
  final String senderID;
  final String chatID;
  final String isSeen;
  final String photoUrl;
  final String senderName;
  final String receiverID;
  final String receiverPhotoUrl;
  final String receiverName;
  
  MyMessage({this.timestamp, this.receiverName, this.photoUrl,this.receiverPhotoUrl, this.receiverID, this.senderName, this.message, this.senderID, this.chatID, this.isSeen});
  
  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "timestamp": timestamp,
      "senderID": senderID,
      "chatID": chatID,
      "isSeen": isSeen,
      "photoUrl": photoUrl,
      "senderName": senderName,
      "receiverID": receiverID,
      "receiverPhotoUrl": receiverPhotoUrl,
      "receiverName": receiverName,
    };
  }
  
  factory MyMessage.fromDocument(DocumentSnapshot documentSnapshot) {
    return MyMessage(
      message: documentSnapshot['message'],
      timestamp: documentSnapshot['timestamp'],
      senderID: documentSnapshot['senderID'],
      isSeen: documentSnapshot['isSeen'],
      chatID: documentSnapshot['chatID'],
      photoUrl: documentSnapshot['photoUrl'],
      receiverID: documentSnapshot['receiverID'],
      senderName: documentSnapshot['senderName'],
      receiverPhotoUrl: documentSnapshot['receiverPhotoUrl'],
      receiverName: documentSnapshot['receiverName']
    );
  }
}

class MessageDBManager {
  Database _messageDatabase;

  Future openMessageDB() async {
    if(_messageDatabase == null)
    {
      _messageDatabase = await openDatabase(
          join(await getDatabasesPath(), "messages.db"),
          version: 1,
          onCreate: (Database db, int version) async {
            await db.execute(
                "CREATE TABLE messages (timestamp INTEGER PRIMARY KEY, receiverName TEXT, receiverPhotoUrl TEXT, receiverID TEXT, photoUrl TEXT, senderName TEXT, isSeen TEXT, chatID TEXT, message TEXT, senderID TEXT)"
            );
          }
      );
    }
  }

  Future<int> saveMessage(MyMessage message) async {
    await openMessageDB();
    return await _messageDatabase.insert('messages', message.toMap());
  }

  Future<List<MyMessage>> loadMessages(String chatID) async {
    await openMessageDB();

    final List<Map<String, dynamic>> maps = await _messageDatabase
        .rawQuery('SELECT * FROM messages WHERE chatID=? ORDER BY timestamp ASC',
        ['$chatID']
    );

    return List.generate(maps.length, (index) {
      return MyMessage(
          message: maps[index]['message'],
          timestamp: maps[index]['timestamp'],
          senderID: maps[index]['senderID'],
          chatID: maps[index]['chatID'],
          senderName: maps[index]['senderName'],
          isSeen: maps[index]['isSeen'],
          photoUrl: maps[index]['photoUrl'],
          receiverID: maps[index]['receiverID'],
          receiverPhotoUrl: maps[index]['receiverPhotoUrl'],
          receiverName: maps[index]['receiverName']
      );
    });
  }

  Future<List<MyMessage>> loadChatHomeMessages() async {
    await openMessageDB();

    final List<Map<String, dynamic>> maps = await _messageDatabase
        .rawQuery('SELECT * FROM messages GROUP BY chatID ORDER BY timestamp DESC');
    //.rawQuery('SELECT senderName, photoUrl, receiverPhotoUrl,  message, timestamp, isSeen, senderID, receiverID FROM messages GROUP BY chatID ORDER BY timestamp DESC');

    return List.generate(maps.length, (index) {
      return MyMessage(
          message: maps[index]['message'],
          timestamp: maps[index]['timestamp'],
          senderID: maps[index]['senderID'],
          chatID: maps[index]['chatID'],
          senderName: maps[index]['senderName'],
          isSeen: maps[index]['isSeen'],
          photoUrl: maps[index]['photoUrl'],
          receiverID: maps[index]['receiverID'],
          receiverPhotoUrl: maps[index]['receiverPhotoUrl'],
          receiverName: maps[index]['receiverName']
      );
    });
  }

  updateField(String chatID) async {
    await openMessageDB();
    await _messageDatabase.rawUpdate('''
    UPDATE messages 
    SET isSeen = ?
    WHERE chatID = ?
    ''',
        ['true', chatID]);
  }

  deleteData() async {
    await openMessageDB();
    await _messageDatabase.delete("messages");
  }

  deleteTable() async {
    await openMessageDB();
    await _messageDatabase.rawDelete("DROP TABLE messages");
  }

  getTimestamp(String chatID) async {
    await openMessageDB();
    final List<Map<String, dynamic>> maps = await _messageDatabase
        .rawQuery('SELECT * FROM messages WHERE chatID=? ORDER BY timestamp DESC LIMIT 1',
        ['$chatID']
    );

    return maps.length == 0 ? 0 : maps[0]['timestamp'];
  }

  getLastMessage() async {
    await openMessageDB();
    final List<Map<String, dynamic>> maps = await _messageDatabase
        .rawQuery('SELECT * FROM messages ORDER BY timestamp DESC LIMIT 1');

    return maps.length == 0 ? 0 : maps[0]['timestamp'];
  }
}

class AdminMessageDBManager {
  Database _messageDatabase;

  Future openMessageDB() async {
    if(_messageDatabase == null)
    {
      _messageDatabase = await openDatabase(
          join(await getDatabasesPath(), "adminMessages.db"),
          version: 1,
          onCreate: (Database db, int version) async {
            await db.execute(
                "CREATE TABLE adminMessages (timestamp INTEGER PRIMARY KEY, receiverName TEXT, receiverPhotoUrl TEXT, receiverID TEXT, photoUrl TEXT, senderName TEXT, isSeen TEXT, chatID TEXT, message TEXT, senderID TEXT)"
            );
          }
      );
    }
  }

  Future<int> saveMessage(MyMessage message) async {
    await openMessageDB();
    return await _messageDatabase.insert('adminMessages', message.toMap());
  }

  Future<List<MyMessage>> loadMessages(String chatID) async {
    await openMessageDB();
    
    final List<Map<String, dynamic>> maps = await _messageDatabase
        .rawQuery('SELECT * FROM adminMessages WHERE chatID=? ORDER BY timestamp ASC',
      ['$chatID']
    );
    
    return List.generate(maps.length, (index) {
      return MyMessage(
        message: maps[index]['message'],
        timestamp: maps[index]['timestamp'],
        senderID: maps[index]['senderID'],
        chatID: maps[index]['chatID'],
        senderName: maps[index]['senderName'],
        isSeen: maps[index]['isSeen'],
        photoUrl: maps[index]['photoUrl'],
        receiverID: maps[index]['receiverID'],
        receiverPhotoUrl: maps[index]['receiverPhotoUrl'],
        receiverName: maps[index]['receiverName']
      );
    });
  }

  Future<List<MyMessage>> loadChatHomeMessages() async {
    await openMessageDB();

    final List<Map<String, dynamic>> maps = await _messageDatabase
        .rawQuery('SELECT * FROM adminMessages GROUP BY chatID ORDER BY timestamp DESC');
        //.rawQuery('SELECT senderName, photoUrl, receiverPhotoUrl,  message, timestamp, isSeen, senderID, receiverID FROM adminMessages GROUP BY chatID ORDER BY timestamp DESC');

    return List.generate(maps.length, (index) {
      return MyMessage(
          message: maps[index]['message'],
          timestamp: maps[index]['timestamp'],
          senderID: maps[index]['senderID'],
          chatID: maps[index]['chatID'],
          senderName: maps[index]['senderName'],
          isSeen: maps[index]['isSeen'],
          photoUrl: maps[index]['photoUrl'],
          receiverID: maps[index]['receiverID'],
          receiverPhotoUrl: maps[index]['receiverPhotoUrl'],
          receiverName: maps[index]['receiverName']
      );
    });
  }

  updateField(String chatID) async {
    await openMessageDB();
    await _messageDatabase.rawUpdate('''
    UPDATE adminMessages 
    SET isSeen = ?
    WHERE chatID = ?
    ''',
        ['true', chatID]);
  }

  deleteData() async {
    await openMessageDB();
    await _messageDatabase.delete("adminMessages");
  }

  deleteTable() async {
    await openMessageDB();
    await _messageDatabase.rawDelete("DROP TABLE adminMessages");
  }
  
  getTimestamp(String chatID) async {
    await openMessageDB();
    final List<Map<String, dynamic>> maps = await _messageDatabase
        .rawQuery('SELECT * FROM adminMessages WHERE chatID=? ORDER BY timestamp DESC LIMIT 1',
        ['$chatID']
    );

    return maps.length == 0 ? 0 : maps[0]['timestamp'];
  }

  getLastMessage() async {
    await openMessageDB();
    final List<Map<String, dynamic>> maps = await _messageDatabase
        .rawQuery('SELECT * FROM adminMessages ORDER BY timestamp DESC LIMIT 1');

    return maps.length == 0 ? 0 : maps[0]['timestamp'];
  }
}