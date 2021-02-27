import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/models/dataModel.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';


class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics"),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child:  StreamBuilder<QuerySnapshot>(
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
                return ListView.builder(
                  itemCount: list.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    PoultryData poultryData = list[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            width: 2.0,
                            color: Colors.black,
                          )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: " + poultryData.name, style: TextStyle(fontWeight: FontWeight.bold),),
                              Text("Males: " + poultryData.males.toString()),
                              Text("Females: " + poultryData.females.toString()),
                              Text("Chicks: " + poultryData.chicks.toString()),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

            }
          },
        ),
      ),
    );
  }
}
