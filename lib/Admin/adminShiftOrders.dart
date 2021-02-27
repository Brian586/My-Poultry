import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_poultry/Config/config.dart';
import '../Widgets/loadingWidget.dart';
import 'adminOrderCard.dart';

class AdminShiftOrders extends StatefulWidget {

  final String name;
  final String phone;
  final String userID;

  AdminShiftOrders({this.name, this.phone, this.userID});

  @override
  _MyOrdersState createState() => _MyOrdersState();
}


class _MyOrdersState extends State<AdminShiftOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 3.0,
        title: Text(
          "My Orders",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.white,),
        //     onPressed: () {
        //       SystemNavigator.pop();
        //     },
        //   ),
        // ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("orders").snapshots(),
        builder: (c, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (c, index) {
                  return FutureBuilder<QuerySnapshot>(
                    future: Firestore.instance.collection("items")
                        .where("shortInfo", whereIn: snapshot.data.documents[index].data[MyPoultry.productID])
                        .getDocuments(),
                    builder: (c, snap) {
                      return snap.hasData
                          ? AdminOrderCard(
                        userID: widget.userID,
                        phone: widget.phone,
                        name: widget.name,
                        itemCount: snap.data.documents.length,
                        data: snap.data.documents,
                        orderID: snapshot.data.documents[index].documentID,
                        orderBy: snapshot.data.documents[index].data["orderBy"],
                        addressID: snapshot.data.documents[index].data["addressID"],
                      )
                          : Center(child: circularProgress(),);
                    },
                  );
                },
          ) : Center(child: circularProgress(),);
        },
      ),
    );
  }
}
