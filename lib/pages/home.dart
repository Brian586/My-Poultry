import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_poultry/models/chartData.dart';
import 'package:my_poultry/models/dataModel.dart';
import 'package:my_poultry/models/healthModel.dart';
import 'package:my_poultry/pages/produceData.dart';
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
  List<ChartData> chartDataList = [];
  Map<DateTime, List<String>> events = {};
  List todoList = [];
  DateTime date;

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    _calendarController = CalendarController();

    await Firestore.instance.collection("vaccines").getDocuments().then((querySnapshot) {
      events = {};

      querySnapshot.documents.forEach((element) {
        Vaccination vaccination = Vaccination.fromDocument(element);
        events[DateTime.fromMillisecondsSinceEpoch(vaccination.dateTime)] = [
          vaccination.vaccineName,
          vaccination.disease
        ];
      });
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

    await Firestore.instance.collection("chartData").orderBy("timestamp", descending: false).getDocuments().then((querySnapshot) {
      chartDataList = [];

      querySnapshot.documents.forEach((element) {
        ChartData chartData = ChartData.fromDocument(element);
        chartDataList.add(chartData);
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

  List<LineSeries<ChartData, String>> getLineSeries() {

    // final List<ChartData> chartData = [
    //   ChartData(2017, 21, 28),
    //   ChartData(2018, 24, 44),
    //   ChartData(2019, 21, 28),
    //   ChartData(2020, 21, 28),
    // ];

    return <LineSeries<ChartData, String>> [
      LineSeries<ChartData, String>(
        animationDuration: 2500,
        dataSource: chartDataList,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
        width: 2,
        name: "Meat",
        markerSettings: MarkerSettings(isVisible: true)
      ),
      LineSeries<ChartData, String>(
          animationDuration: 2500,
          dataSource: chartDataList,
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.y2,
          width: 2,
          name: "Eggs",
          markerSettings: MarkerSettings(isVisible: true)
      )
    ];
  }

  addProduceData() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context)=> ProduceData()));

    getData();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    setState(() {
      todoList = events;
      date = day;
    });
  }

  displayEvents()
  {
    return todoList.length == 0 ? Text("") : Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(color: Colors.black38, offset: Offset(2.0, 2.0), blurRadius: 6.0)
          ]
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vaccination for " + DateFormat("MMM dd").format(date), style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(height: 10.0,),
            ListView.builder(
              itemCount: todoList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                String event = todoList[index];

                return Text(event);
              },
            )
          ],
        ),
      ),
    );
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
                  events: events,
                  onDaySelected: _onDaySelected,
                ),
                displayEvents(),
                SizedBox(height: 40.0,),
                Heading(width: 125.0, title: "Production Graph",),
                SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  title: ChartTitle(text: "Production"),
                  legend: Legend(
                      isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap
                  ),
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    labelFormat: "{value}",
                    axisLine: AxisLine(width: 0.0),
                    majorTickLines: MajorTickLines(color: Colors.transparent)
                  ),
                  series: getLineSeries(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
                SizedBox(height: 20.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 40,
                      //width: 180,
                      child: RaisedButton.icon(
                        onPressed: addProduceData,
                        color: Colors.pink,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        icon: Icon(Icons.add, color: Colors.white,),
                        label: Text("Add Produce Data", style: GoogleFonts.fredokaOne(color: Colors.white),),
                        elevation: 5.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50.0,),
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

