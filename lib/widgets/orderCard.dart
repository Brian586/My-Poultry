import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/Orders/OrderDetailsPage.dart';
import 'package:my_poultry/models/productModel.dart';

int counter = 0;
class OrderCard extends StatelessWidget {

  final int itemCount;
  final List<DocumentSnapshot> data;
  final String orderID;

  OrderCard({Key key, this.data, this.itemCount, this.orderID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: () {
        Route route;
        if(counter == 0)
          {
            counter = counter + 1;
            route = MaterialPageRoute(builder: (context) => OrderDetails(orderID: orderID));
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

            return sourceOrderInfo(model, context);
          },
        ),
      ),
    );
  }
}



Widget sourceOrderInfo(Product model, BuildContext context,
    {Color background})
{
  double width =  MediaQuery.of(context).size.width;

  return  Container(
    height: 170.0,
    width: width,
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(color: Colors.black38, offset: Offset(2.0, -2.0), blurRadius: 6.0)
        ]
    ),
    child: Row(
      children: [
        Container(
          width: 140,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
              image: DecorationImage(
                  image: NetworkImage(model.thumbnailUrl),
                  fit: BoxFit.cover
              )
          ),
        ),
        SizedBox(width: 10.0,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.0,),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(model.title, style: TextStyle(color: Colors.black, fontSize: 14.0),),
                    )
                  ],
                ),
              ),
              SizedBox(height: 5.0,),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(model.shortInfo, style: TextStyle(color: Colors.black54, fontSize: 12.0),),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20.0,),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: [
                            Text(
                              "Total Price: ",
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey
                              ),
                            ),
                            Text(
                              "Ksh ",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.red
                              ),
                            ),
                            Text(
                              (model.price).toString(),
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.red
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),

              Flexible(
                child: Container(

                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}
