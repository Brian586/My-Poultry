import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_poultry/Address/address.dart';
import 'package:my_poultry/Admin/uploadItems.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/models/address.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';
import 'package:my_poultry/widgets/orderCard.dart';
import 'package:url_launcher/url_launcher.dart';


String getOrderId="";
class AdminOrderDetails extends StatelessWidget {

  final String orderID;
  final String orderBy;
  final String addressID;
  final String name;
  final String phone;
  final String userID;


  AdminOrderDetails({Key key, this.name, this.phone, this.userID, this.addressID, this.orderBy, this.orderID}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    getOrderId = orderID;

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
          "Order Details",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: MyPoultry.firestore
                  .collection(MyPoultry.collectionOrders)
                  .document(getOrderId).get(),
              builder: (c, snapshot) {
                Map dataMap;
                if(snapshot.hasData)
                {
                  dataMap = snapshot.data.data;
                }

                return snapshot.hasData
                    ? Container(
                  child: Column(
                    children: [
                      //AdminStatusBanner(status: dataMap[MimiShop.isSuccess],),
                      SizedBox(height: 10.0,),
                      // Padding(
                      //   padding: EdgeInsets.all(4.0),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(
                      //       "Ksh " + dataMap[MimiShop.totalAmount].toString(),
                      //       style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.all(4.0),
                      //   child: Text("Order ID: " + getOrderId),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("Ordered at: " + DateFormat("dd MMMM, yyyy - hh:mm aa")
                            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dataMap["orderTime"]))),
                          style: TextStyle(color: Colors.grey, fontSize: 16.0),
                        ),
                      ),
                      Divider(height: 2.0,),
                      FutureBuilder<QuerySnapshot>(
                        future: MyPoultry.firestore.collection("items")
                            .where("shortInfo", whereIn: dataMap[MyPoultry.productID])
                            .getDocuments(),
                        builder: (c, dataSnapshot) {
                          return dataSnapshot.hasData
                              ? OrderCard(
                            itemCount: dataSnapshot.data.documents.length,
                            data: dataSnapshot.data.documents,
                          )
                              : Center(child: circularProgress(),);
                        },
                      ),
                      Divider(height: 2.0,),
                      FutureBuilder<DocumentSnapshot>(
                        future: MyPoultry.firestore
                            .collection(MyPoultry.collectionUser)
                            .document(orderBy)
                            .collection(MyPoultry.subCollectionAddress).document(addressID).get(),
                        builder: (c, snap) {
                          return snap.hasData
                              ? AdminShippingDetails(
                            userID: userID,
                            phone: phone,
                            name: name,
                            model: AddressModel.fromJson(snap.data.data),
                          )
                              : Center(child: circularProgress(),);
                        },
                      )
                    ],
                  ),
                )
                    : Center(child: circularProgress(),);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AdminStatusBanner extends StatelessWidget {

  final bool status;

  AdminStatusBanner({Key key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String msg;
    IconData iconData;

    status ? iconData = Icons.done : iconData = Icons.cancel;
    status ? msg = "Successful" : msg = "UnSuccessful";

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue[900], Colors.lightBlue],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp
          )
      ),
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              SystemNavigator.pop();
            },
            child: Container(
              child: Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.white,),
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Text(
            "Order Shipped " + msg,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 5.0,),
          CircleAvatar(
            radius: 8.0,
            backgroundColor: Colors.grey,
            child: Center(
              child: Icon(iconData, color: Colors.white, size: 14.0,),
            ),
          )
        ],
      ),
    );
  }
}

class AdminShippingDetails extends StatelessWidget {
  final AddressModel model;
  final String name;
  final String phone;
  final String userID;

  AdminShippingDetails({Key key, this.model, this.name, this.userID, this.phone}) : super(key: key);


  confirmedParcelShifted(BuildContext context, String mOrderId) {
    MyPoultry.firestore
        .collection(MyPoultry.collectionOrders)
        .document(mOrderId).delete();

    getOrderId = "";

    Route route = MaterialPageRoute(builder: (context)=> UploadPage(
      userID: userID,
      phone: phone,
      name: name,
    ));
    Navigator.pushReplacement(context, route);

    Fluttertoast.showToast(msg: "Order has been Confirmed");
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.0,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 5.0,),
          child: Text("Shipment Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 5.0,),
          width: screenWidth,
          child: Table(
            children: [

              TableRow(
                  children: [
                    KeyText(msg: "Name",),
                    Text(model.name)
                  ]
              ),

              TableRow(
                  children: [
                    KeyText(msg: "Phone Number",),
                    Text(model.phoneNumber)
                  ]
              ),
              // TableRow(
              //     children: [
              //       KeyText(msg: "Flat Number",),
              //       Text(model.flatNumber)
              //     ]
              // ),
              TableRow(
                  children: [
                    KeyText(msg: "City",),
                    Text(model.city)
                  ]
              ),
              TableRow(
                  children: [
                    KeyText(msg: "State",),
                    Text(model.state)
                  ]
              ),
              // TableRow(
              //     children: [
              //       KeyText(msg: "Pin Code",),
              //       Text(model.pincode)
              //     ]
              // ),
            ],
          ),
        ),

        SizedBox(height: 10.0,),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.center,
              child: Text("Contact Your Client", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),)),
        ),

        SizedBox(height: 10.0,),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Container(
                height: 50,
                //width: 180,
                child: RaisedButton.icon(
                  onPressed: () => launch("tel:${model.phoneNumber}"),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)
                  ),
                  label: Text("Call", style: GoogleFonts.fredokaOne(color: Colors.black, fontSize: 17.0),),
                  icon: Icon(Icons.phone, color: Colors.blue,),
                  elevation: 5.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Container(
                height: 50,
                //width: 180,
                child: RaisedButton.icon(
                  onPressed: () => launch("sms:${model.phoneNumber}"),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)
                  ),
                  icon: Icon(Icons.message_outlined, color: Colors.blue,),
                  label: Text("Chat", style: GoogleFonts.fredokaOne(color: Colors.black, fontSize: 17.0),),
                  elevation: 5.0,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 30.0,),

        Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: () {
                confirmedParcelShifted(context, getOrderId);
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 40.0,
                height: 50.0,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue[900], Colors.lightBlue],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 0.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp
                    )
                ),
                child: Center(
                  child: Text("Confirm Order", style: TextStyle(color: Colors.white, fontSize: 15.0),),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

}
