import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/models/productModel.dart';
import 'package:my_poultry/widgets/productLayout.dart';
import 'adminOrderDetails.dart';


int counter=0;
class AdminOrderCard extends StatelessWidget
{

  final int itemCount;
  final List<DocumentSnapshot> data;
  final String orderID;
  final String addressID;
  final String orderBy;
  final String name;
  final String phone;
  final String userID;


  AdminOrderCard({Key key, this.data, this.itemCount, this.name, this.phone, this.userID,
    this.orderID, this.addressID, this.orderBy}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return InkWell(
      onTap: () {
        Route route;
        if(counter == 0)
        {
          counter = counter + 1;
          route = MaterialPageRoute(builder: (context) => AdminOrderDetails(
            userID: userID,
              phone: phone,
              name: name,
              orderID: orderID, orderBy: orderBy, addressID: addressID));
        }
        Navigator.push(context, route);
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        height: itemCount * 190.0,
        child: ListView.builder(
          itemCount: itemCount,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (c, index) {
            Product model = Product.fromJson(data[index].data);

            return ProductLayout(product: model, context: c,);
          },
        ),
      ),
    );
  }
}
