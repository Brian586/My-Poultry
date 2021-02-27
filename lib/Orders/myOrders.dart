import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/widgets/orderCard.dart';
import '../Widgets/loadingWidget.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}



class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          elevation: 3.0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue[900], Colors.lightBlue],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp
                )
            ),
          ),
          title: Text(
            "My Orders",
            style: TextStyle(
                color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.white,),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: MyPoultry.firestore
              .collection(MyPoultry.collectionUser)
              .document(MyPoultry.sharedPreferences.getString(MyPoultry.userUID))
              .collection(MyPoultry.collectionOrders).snapshots(),
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
                            ? OrderCard(
                              itemCount: snap.data.documents.length,
                              data: snap.data.documents,
                          orderID: snapshot.data.documents[index].documentID,
                        )
                            : Center(child: circularProgress(),);
                      },
                    );
              },
            )
                : Center(child: circularProgress(),);
          },
        ),
      ),
    );
  }
}
