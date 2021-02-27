import 'package:flutter/material.dart';
import 'package:my_poultry/models/productModel.dart';
import 'package:my_poultry/pages/productPage.dart';


class ProductLayout extends StatelessWidget {

  final BuildContext context;
  final Product product;

  ProductLayout({this.product, this.context});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Route route = MaterialPageRoute(builder: (context)=> ProductPage(product: product));
          Navigator.push(context, route);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(color: Colors.black38, offset: Offset(2.0, -2.0), blurRadius: 6.0)
                  ]
              ),
              child: Row(
                children: [
                    Hero(
                    tag: product.thumbnailUrl,
                    child: Container(
                      height: 190,
                      width: 140,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
                          image: DecorationImage(
                              image: NetworkImage(product.thumbnailUrl),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.0,),
                        Text(product.title.trimRight(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0),),
                        SizedBox(height: 5.0,),
                        Text(product.shortInfo.trimRight(), style: TextStyle(color: Colors.black, fontSize: 14.0),),
                        SizedBox(height: 5.0,),
                        Row(
                          children: [
                            Text(
                              "Ksh ",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              (product.price).toString(),
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              )
          ),
        )
    );
  }
}
