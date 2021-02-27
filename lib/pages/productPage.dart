import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/Address/address.dart';
import 'package:my_poultry/models/productModel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chatDetails.dart';


class ProductPage extends StatefulWidget {

  final Product product;

  ProductPage({this.product});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: size.height * 0.35,
                width: size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.product.thumbnailUrl),
                    fit: BoxFit.cover
                  )
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                widget.product.title,
                style: boldTextStyle,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                widget.product.longDescription,
                style: TextStyle(fontSize: 17.0),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "Ksh " + widget.product.price.toString(),
                style: boldTextStyle,
              ),
              SizedBox(
                height: 10.0,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Container(
                height: 50,
                //width: 180,
                child: RaisedButton.icon(
                  //onPressed: ()=> checkItemInCart(widget.itemModel.shortInfo, context),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Address(totalAmount: widget.product.price,)));
                  },
                  color: Colors.pink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)
                  ),
                  icon: Icon(Icons.add_shopping_cart_outlined, color: Colors.white,),
                  label: Text("Check Out", style: GoogleFonts.fredokaOne(color: Colors.white, fontSize: 17.0),),
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
                  onPressed: () => launch("tel:${widget.product.phone}"),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)
                  ),
                  label: Text("Call", style: GoogleFonts.fredokaOne(color: Colors.black, fontSize: 17.0),),
                  icon: Icon(Icons.phone, color: Colors.pink,),
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
                  onPressed: () {
                    Route route = MaterialPageRoute(builder: (context)=> ChatDetails(userId: widget.product.publisherID,));
                    Navigator.push(context, route);
                  },//() => launch("sms:${widget.itemModel.phone}"),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)
                  ),
                  icon: Icon(Icons.message_outlined, color: Colors.pink,),
                  label: Text("Chat", style: GoogleFonts.fredokaOne(color: Colors.black, fontSize: 17.0),),
                  elevation: 5.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


const boldTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);