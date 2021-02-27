import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/pages/agrovetProducts.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class PaymentPage extends StatefulWidget {

  final String addressId;
  final double totalAmount;

  PaymentPage({Key key, this.totalAmount, this.addressId}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}




class _PaymentPageState extends State<PaymentPage> {


  addOrderDetails() {
    writeOrderDetailsForUser({
      MyPoultry.addressID: widget.addressId,
      MyPoultry.totalAmount: widget.totalAmount,
      "orderBy": MyPoultry.sharedPreferences.getString(MyPoultry.userUID),
      MyPoultry.productID: MyPoultry.sharedPreferences.getStringList(MyPoultry.userCartList),
      MyPoultry.paymentDetails: "Cash on delivery",
      MyPoultry.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      MyPoultry.isSuccess: true,
    });

    writeOrderDetailsForAdmin({
      MyPoultry.addressID: widget.addressId,
      MyPoultry.totalAmount: widget.totalAmount,
      "orderBy": MyPoultry.sharedPreferences.getString(MyPoultry.userUID),
      MyPoultry.productID: MyPoultry.sharedPreferences.getStringList(MyPoultry.userCartList),
      MyPoultry.paymentDetails: "Cash on delivery",
      MyPoultry.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      MyPoultry.isSuccess: true,
    }).whenComplete(() => {
      emptyCartNow()
    });
  }

  emptyCartNow() {

    MyPoultry.sharedPreferences.setStringList(MyPoultry.userCartList, ["garbageValue"]);
    List tempList = MyPoultry.sharedPreferences.getStringList(MyPoultry.userCartList);

    Firestore.instance.collection("users").document(MyPoultry.sharedPreferences.getString(MyPoultry.userUID))
        .updateData({
      MyPoultry.userCartList: tempList,
    }).then((value) {
      MyPoultry.sharedPreferences.setStringList(MyPoultry.userCartList, tempList);
    });

    Fluttertoast.showToast(msg: "Congratulations! Your order has been placed successfully");

    Route route = MaterialPageRoute(builder: (context) => AgrovetProducts());
    Navigator.pushReplacement(context, route);
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async {
    await MyPoultry.firestore.collection(MyPoultry.collectionUser)
        .document(MyPoultry.sharedPreferences.getString(MyPoultry.userUID))
        .collection(MyPoultry.collectionOrders)
        .document(MyPoultry.sharedPreferences.getString(MyPoultry.userUID) + data['orderTime'])
        .setData(data);
  }

  Future writeOrderDetailsForAdmin(Map<String, dynamic> data) async {
    await MyPoultry.firestore
        .collection(MyPoultry.collectionOrders)
        .document(MyPoultry.sharedPreferences.getString(MyPoultry.userUID) + data['orderTime'])
        .setData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset("images/cash.png"),
              ),
              SizedBox(height: 10.0,),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.lightBlueAccent,
                onPressed: ()=> addOrderDetails(),
                child: Text("Place Order", style: TextStyle(fontSize: 30.0),),
              )
            ],
          ),
        ),
      ),
    );
  }
}
