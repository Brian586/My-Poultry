import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/models/chartData.dart';
import 'package:my_poultry/models/dataModel.dart';
import 'package:my_poultry/widgets/customPercentIndicator.dart';
import 'package:my_poultry/widgets/drawer.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  CalendarController _calendarController;
  bool loading = false;
  List<PoultryData> list = [];

  @override
  void initState() {
    super.initState();

    getData();
    _calendarController = CalendarController();
  }

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    await Firestore.instance
        .collection("poultryData")
        .orderBy("timestamp", descending: true)
        .getDocuments().then((querySnapshot) {
          list = [];

          querySnapshot.documents.forEach((element) {
            PoultryData poultryData = PoultryData.fromDocument(element);
            list.add(poultryData);
          });
    });

    setState(() {
      loading = false;
    });

  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  List<LineSeries<ChartData, num>> getLineSeries() {

    final List<ChartData> chartData = [
      ChartData(2017, 21, 28),
      ChartData(2018, 24, 44),
      ChartData(2019, 21, 28),
      ChartData(2020, 21, 28),
    ];

    return <LineSeries<ChartData, num>> [
      LineSeries<ChartData, num>(
        animationDuration: 2500,
        dataSource: chartData,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
        width: 2,
        name: "Meat",
        markerSettings: MarkerSettings(isVisible: true)
      ),
      LineSeries<ChartData, num>(
          animationDuration: 2500,
          dataSource: chartData,
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.y2,
          width: 2,
          name: "Eggs",
          markerSettings: MarkerSettings(isVisible: true)
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        //iconTheme: IconThemeData(color: Colors.black),
        //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        //elevation: 0.0,
        title: Text("Home"),
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 40.0),
          child: Align(
            alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("Reports", style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 20.0),),
              )),
        ),
      ),
      body: loading ? circularProgress() : RefreshIndicator(
        onRefresh: getData,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Heading(width: 140.0, title: "Number of Poultry",),
                SizedBox(height: 20.0,),
                Container(
                  height: 150.0,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    itemCount: list.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      PoultryData poultryData = list[index];
                      int total = poultryData.males + poultryData.females + poultryData.chicks;

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CustomIndicator(
                          color: Colors.green[500],
                          amount: total.toString(),
                          category: poultryData.name,
                          percent: (total/100),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 40.0,),
                Heading(width: 150.0, title: "Vaccination Calendar",),
                TableCalendar(
                  calendarController: _calendarController,
                ),
                SizedBox(height: 40.0,),
                Heading(width: 125.0, title: "Production Graph",),
                SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  title: ChartTitle(text: "Production"),
                  legend: Legend(
                      isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap
                  ),
                  primaryXAxis: NumericAxis(
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    interval: 1,
                    majorGridLines: MajorGridLines(width: 0.0)
                  ),
                  primaryYAxis: NumericAxis(
                    labelFormat: "{value}",
                    axisLine: AxisLine(width: 0.0),
                    majorTickLines: MajorTickLines(color: Colors.transparent)
                  ),
                  series: getLineSeries(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Heading extends StatelessWidget {

  final String title;
  final double width;

  Heading({this.width, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 3.0,
                  //width: MediaQuery.of(context).size.width,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              Container(
                height: 3.0,
                width: width,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

