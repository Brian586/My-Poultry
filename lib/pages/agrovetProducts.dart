import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/Admin/adminLogin.dart';
import 'package:my_poultry/models/productModel.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';
import 'package:my_poultry/widgets/productLayout.dart';


class AgrovetProducts extends StatefulWidget {
  @override
  _AgrovetProductsState createState() => _AgrovetProductsState();
}

class _AgrovetProductsState extends State<AgrovetProducts> {

  Future futureResults;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    getPosts();
  }

  Future<void> getPosts() async {
    setState(() {
      loading = true;
    });

    Future querySnapshot = Firestore.instance.collection("products")
    //.where("country", isEqualTo: widget.country).where("city", isEqualTo: widget.city)
    //.where("category", isEqualTo: widget.category.name)
        //.limit(15)
        .orderBy("publishedDate", descending: true).getDocuments();

    setState(() {
      futureResults = querySnapshot;
      //models = querySnapshot.documents.map((document) => ItemModel.fromJson(document.data)).toList();
      loading = false;
    });
  }

  displayList() {
    return FutureBuilder<QuerySnapshot>(
      future: futureResults,
      builder: (BuildContext context, snapshot) {
        if(!snapshot.hasData)
        {
          return circularProgress();
        }
        else
        {
          List<Product> postList = [];
          snapshot.data.documents.forEach((element) {
            Product model = Product.fromDocument(element);
            postList.add(model);
          });

          if(postList.length == 0)
          {
            return Center(child: Text("No Data"),);
          }
          else
          {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: postList.length,
              itemBuilder: (BuildContext context, int index) {
                Product model = postList[index];

                return ProductLayout(
                  product: model,
                  context: context,
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

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Agrovet Products",
        ),
        // bottom: PreferredSize(
        //   preferredSize: Size(width, 60.0),
        //   child: Container(
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: InkWell(
        //         onTap: () {
        //           // Route route = MaterialPageRoute(builder: (context)=> SearchProduct());
        //           // Navigator.push(context, route);
        //         },
        //         child: Container(
        //           height: 40.0,
        //           width: width * 0.9,
        //           decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(30.0),
        //               color: Colors.white70
        //           ),
        //           child: Row(
        //             children: [
        //               SizedBox(width: 10.0,),
        //               Icon(Icons.search, color: Colors.black,),
        //               SizedBox(width: 10.0,),
        //               Text("Search here...")
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ),
      body: loading ? circularProgress() : RefreshIndicator(child:  displayList(), onRefresh: getPosts),
    );
  }
}
