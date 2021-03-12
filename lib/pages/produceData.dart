import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/pages/health.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';


class ProduceData extends StatefulWidget {
  @override
  _ProduceDataState createState() => _ProduceDataState();
}

class _ProduceDataState extends State<ProduceData> {

  TextEditingController eggs = TextEditingController();
  TextEditingController meat = TextEditingController();
  bool loading = false;


  saveData() async {
    setState(() {
      loading = true;
    });

    await Firestore.instance.collection("chartData").add({
      "eggs": int.parse(eggs.text.trim()),
      "meat": int.parse(meat.text.trim()),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    }).then((value) => Fluttertoast.showToast(msg: "Uploaded Successfully"));

    setState(() {
      loading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produce Data"),
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            MyTextField(
              controller: eggs,
              hintText: "Number of Eggs",
              keyboardType: TextInputType.number,
            ),
            MyTextField(
              controller: meat,
              hintText: "Meat",
              keyboardType: TextInputType.number,
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
                    onPressed: saveData,
                    color: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    icon: Icon(Icons.save_outlined, color: Colors.white,),
                    label: Text("Save Data", style: GoogleFonts.fredokaOne(color: Colors.white),),
                    elevation: 5.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
