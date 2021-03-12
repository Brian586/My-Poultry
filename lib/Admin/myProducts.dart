import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_poultry/models/productModel.dart';
import 'package:my_poultry/pages/updatePage.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';
import 'package:my_poultry/widgets/productLayout.dart';


class MyProducts extends StatefulWidget {
  
  final String userId;
  
  MyProducts({this.userId});
  
  @override
  _MyProductsState createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {

  Future futurePosts;
  
  @override
  void initState() {
    super.initState();
    
    getUserPosts();
  }
  
  Future<void> getUserPosts() async {
    Future posts = Firestore.instance.collection("products").where("publisherID", isEqualTo: widget.userId).orderBy("publishedDate", descending: true).getDocuments();

    setState(() {
      futurePosts = posts;
    });
  }

  deletePost(Product product) async {
    await Firestore.instance.collection("products").document(product.productId).delete().then((value) {
      Fluttertoast.showToast(msg: "Deleted Successfully");
    });

    getUserPosts();
  }

  updatePost(Product product) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdatePage(product: product,)));

    getUserPosts();
  }

  choiceAction(String choice, Product product){
    if(choice == Options.delete){
      deletePost(product);
    }else if(choice == Options.update){
      updatePost(product);
    }
  }


  displayPosts() {
    return FutureBuilder<QuerySnapshot>(
      future: futurePosts,
      builder: (BuildContext context, snapshot) {
        if(!snapshot.hasData)
          {
            return circularProgress();
          }
        else
          {
            List<Product> postList = [];
            snapshot.data.documents.forEach((element) {
              Product product = Product.fromDocument(element);
              postList.add(product);
            });

            if(postList.length == 0)
              {
                return Center(child: Text("You Don't have any uploads"),);
              }
            else
              {
                return ListView.builder(
                  itemCount: postList.length,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    Product product = postList[index];

                    return Stack(
                      children: [
                        ProductLayout(context: context, product: product,),
                        Positioned(
                          bottom: 10.0,
                          right: 15.0,
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, size: 25.0,),
                            offset: Offset(0.0, 0.0),
                            onSelected: (choice) => choiceAction(choice, product),
                            itemBuilder: (BuildContext context){
                              return Options.choices.map((String choice){
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),
                        )
                      ],
                    );
                  },
                );
              }
          }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Products"),
      ),
      body: displayPosts(),
    );
  }
}


class Options {
  static const String delete = "Delete";
  static const String update = "Update";

  static const List<String> choices = [
    update,
    delete
  ];
}