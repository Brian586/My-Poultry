import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/productModel.dart';
import '../widgets/loadingWidget.dart';
import '../widgets/loadingWidget.dart';
import '../widgets/productLayout.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  Future futureResults;
  bool loading = false;
  TextEditingController search = TextEditingController();


  controlSearching() async {
    setState(() {
      loading = true;
    });

    if(search.text.isNotEmpty)
      {
        Future results = Firestore.instance.collection("products")
            .where("searchKey", isGreaterThanOrEqualTo: search.text.trim())
            //.orderBy("publishedDate", descending: true)
            .getDocuments();

        setState(() {
          loading = false;
          futureResults = results;
        });
      }
    else
      {
        setState(() {
          loading = false;
        });
      }
  }

  display() {
    if(futureResults == null)
      {
        return Center(child: Text("Search", style: TextStyle(color: Colors.grey, fontWeight:  FontWeight.bold),),);
      }
    else
      {
        return FutureBuilder<QuerySnapshot>(
          future: futureResults,
          builder: (context, snap) {
            if(!snap.hasData)
              {
                return circularProgress();
              }
            else
              {
                List<Product> postList = [];
                snap.data.documents.forEach((element) {
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
  }


  AppBar searchBar(Size size) {

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.pink,),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Container(
        width: size.width,
        height: 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.grey.withOpacity(0.2)
        ),
        child: TextFormField(
          controller: search,
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                // borderSide: BorderSide(
                //   //width: 1.0,
                // )
            ),
            focusColor: Theme.of(context).primaryColor,
            hintText: "Search here...",
            suffix: IconButton(
              icon: Icon(Icons.search, color: Colors.grey,),
              onPressed: controlSearching,
            ),
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.clear, color: search.text.isNotEmpty ? Colors.pink : Colors.grey,),
          onPressed: () {
            setState(() {
              search.clear();
            });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: searchBar(size),
      body: loading ? circularProgress() : display(),
    );
  }
}
