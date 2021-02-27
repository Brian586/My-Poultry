import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/Counters/changeAddresss.dart';
import 'package:my_poultry/models/address.dart';
import 'package:my_poultry/pages/paymentPage.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';
import 'package:my_poultry/widgets/wideButton.dart';
import 'package:provider/provider.dart';

import 'addAddress.dart';

class Address extends StatefulWidget
{
  final int totalAmount;

  const Address({Key key, this.totalAmount}) : super(key: key);

  @override
  _AddressState createState() => _AddressState();
}


class _AddressState extends State<Address>
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Address"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Select Address",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
          ),
          Consumer<AddressChanger>(builder: (context, address, c) {
            return Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: MyPoultry.firestore
                    .collection(MyPoultry.collectionUser)
                    .document(MyPoultry.sharedPreferences
                    .getString(MyPoultry.userUID))
                    .collection(MyPoultry.subCollectionAddress).snapshots(),
                builder: (context, snapshot) {
                  return !snapshot.hasData ?
                      Center(child: circularProgress(),) :
                      snapshot.data.documents.length == 0 ?
                          noAddressCard() :
                          ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {

                              return AddressCard(
                                currentIndex: address.count,
                                value: index,
                                addressId: snapshot.data.documents[index].documentID,
                                totalAmount: widget.totalAmount,
                                model: AddressModel.fromJson(snapshot.data.documents[index].data),
                              );
                            },
                          );
                },
              ),
            );
          })
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Route route = MaterialPageRoute(builder: (context)=> AddAddress());
            Navigator.push(context, route);
          },
          label: Text("Add new Address"),
        backgroundColor: Colors.pink,
        icon: Icon(Icons.add_location, color: Colors.white,),
      ),
    );
  }

  noAddressCard() {
    return Card(
      color: Colors.pink.withOpacity(0.4),
      child: Container(
        height: 100.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location, color: Colors.white,),
            Text("No shipment Address has been saved."),
            Text("Add shipment Address")
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {

  final AddressModel model;
  final int currentIndex;
  final int value;
  final String addressId;
  final int totalAmount;

  AddressCard({Key key, this.model, this.totalAmount, this.value, this.addressId, this.currentIndex}) : super(key: key);

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Provider.of<AddressChanger>(context, listen: false).displayResult(widget.value);
      },
      child: Card(
        color: Colors.pink.withOpacity(0.4),
        child: Column(
          children: [
            Row(
              children: [
                Radio(
                    value: widget.value,
                    groupValue: widget.currentIndex,
                    activeColor: Colors.pink,
                    onChanged: (val) {
                      Provider.of<AddressChanger>(context, listen: false).displayResult(val);
                    }
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: screenWidth * 0.8,
                      child: Table(
                        children: [

                          TableRow(
                            children: [
                              KeyText(msg: "Name",),
                              Text(widget.model.name)
                            ]
                          ),

                          TableRow(
                              children: [
                                KeyText(msg: "Phone Number",),
                                Text(widget.model.phoneNumber)
                              ]
                          ),
                          TableRow(
                              children: [
                                KeyText(msg: "Flat Number",),
                                Text(widget.model.flatNumber)
                              ]
                          ),
                          TableRow(
                              children: [
                                KeyText(msg: "City",),
                                Text(widget.model.city)
                              ]
                          ),
                          TableRow(
                              children: [
                                KeyText(msg: "State",),
                                Text(widget.model.state)
                              ]
                          ),
                          TableRow(
                              children: [
                                KeyText(msg: "Pin Code",),
                                Text(widget.model.pincode)
                              ]
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
            widget.value == Provider.of<AddressChanger>(context).count
                ? WideButton(
              message: "Proceed",
              onPressed: () {
                Route route = MaterialPageRoute(builder: (context)=> PaymentPage(
                  addressId: widget.addressId,
                  totalAmount: widget.totalAmount
                ));

                Navigator.push(context, route);

              },
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}





class KeyText extends StatelessWidget {

  final String msg;

  KeyText({Key key, this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    );
  }
}
