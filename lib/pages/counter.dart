import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/models/category.dart';
import 'package:my_poultry/models/dataModel.dart';
import 'package:my_poultry/pages/addData.dart';
import 'package:my_poultry/pages/statistics.dart';
import 'package:my_poultry/widgets/categoryDesign.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';
import 'package:my_poultry/widgets/poultryDataLayout.dart';


class CounterPage extends StatefulWidget {
  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {

  String categoryType = "All";
  int id = 1;

  createCarousel() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categoryList.length, (index) {
          Category category = categoryList[index];

          return CategoryDesign(
            category: category,
            id: id,
            onTap: () {
              setState(() {
                categoryType = category.title;
                id = category.id;
              });
            },
          );
        }),
      ),
    );
  }

  createDetailsSection() {
    if(categoryType == "All")
      {
        return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("poultryData").orderBy("timestamp", descending: true).snapshots(),
          builder: (BuildContext context, snapshot) {
            if(!snapshot.hasData)
              {
                return circularProgress();
              }
            else
              {
                List<PoultryData> list = [];

                snapshot.data.documents.forEach((element) {
                  PoultryData poultryData = PoultryData.fromDocument(element);
                  list.add(poultryData);
                });
                // List dataList = snapshot.data;
                // dataList.forEach((element) {
                //   PoultryData poultryData = PoultryData.fromDocument(element);
                //   list.add(poultryData);
                // });

                if(list.length == 0)
                  {
                    return Center(child: Text("No Data"),);
                  }
                else
                  {
                    return Column(
                      children: [
                        ListView.builder(
                          itemCount: list.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return PoultryDataLayout(poultryData: list[index],);
                          },
                        ),
                        RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)
                          ),
                            color: Colors.green,
                            onPressed: () {
                              Route route = MaterialPageRoute(builder: (context)=> StatisticsPage());
                              Navigator.push(context, route);
                            },
                            elevation: 5.0,
                            icon: Icon(Icons.stacked_line_chart, color: Colors.white,),
                            label: Text("Statistics", style: TextStyle(color: Colors.white),)
                        )
                      ],
                    );
                  }

              }
          },
        );
      }
    else
      {
        return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("poultryData").where("name", isEqualTo: categoryType).orderBy("timestamp", descending: true).snapshots(),
          builder: (BuildContext context, snapshot) {
            if(!snapshot.hasData)
            {
              return circularProgress();
            }
            else
            {
              List<PoultryData> list = [];

              snapshot.data.documents.forEach((element) {
                PoultryData poultryData = PoultryData.fromDocument(element);
                list.add(poultryData);
              });
              // List dataList = snapshot.data;
              // dataList.forEach((element) {
              //   PoultryData poultryData = PoultryData.fromDocument(element);
              //   list.add(poultryData);
              // });

              if(list.length == 0)
              {
                return Center(child: Text("No Data"),);
              }
              else
              {
                return ListView.builder(
                  itemCount: list.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return PoultryDataLayout(poultryData: list[index],);
                  },
                );
              }

            }
          },
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Route route = MaterialPageRoute(builder: (context)=> AddData(category: categoryType,));
            Navigator.push(context, route);
          },
          icon: Icon(Icons.add, color: Colors.white,),
          label: Text("Add")
      ),
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     categoryType == "All" ? FloatingActionButton.extended(
      //         backgroundColor: Colors.green,
      //         onPressed: () {},
      //         icon: Icon(Icons.stacked_line_chart, color: Colors.white,),
      //         label: Text("Statistics")
      //     ): Text(""),
      //     SizedBox(width: 10.0,),
      //     FloatingActionButton.extended(
      //         onPressed: () {
      //           Route route = MaterialPageRoute(builder: (context)=> AddData(category: categoryType,));
      //           Navigator.push(context, route);
      //         },
      //         icon: Icon(Icons.add, color: Colors.white,),
      //         label: Text("Add")
      //     ),
      //   ],
      // ),
      appBar: AppBar(
        title: Text("Counter"),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            createCarousel(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                thickness: 3,
              ),
            ),
            createDetailsSection()
          ],
        ),
      ),
    );
  }
}
