import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_poultry/models/category.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';


class AddData extends StatefulWidget {

  final String category;

  AddData({this.category});

  @override
  _AddDataState createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController malesTextEditingController = TextEditingController();
  TextEditingController femalesTextEditingController = TextEditingController();
  TextEditingController chicksTextEditingController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();

    if(widget.category != "All")
      {
        setState(() {
          nameTextEditingController.text = widget.category;
        });
      }
  }

  saveInfo() async {
    setState(() {
      loading = true;
    });

    if(nameTextEditingController.text.isNotEmpty
        && malesTextEditingController.text.isNotEmpty
        && femalesTextEditingController.text.isNotEmpty
        && chicksTextEditingController.text.isNotEmpty)
      {
        await Firestore.instance.collection("poultryData").add({
          "name": nameTextEditingController.text.trim(),
          "males": int.parse(malesTextEditingController.text.trim()),
          "females": int.parse(femalesTextEditingController.text.trim()),
          "chicks": int.parse(chicksTextEditingController.text.trim()),
          "timestamp": DateTime.now().millisecondsSinceEpoch
        }).then((value) => Fluttertoast.showToast(msg: "Saved Successfully"));

        if(widget.category == "All")
          {
            nameTextEditingController.clear();
          }
        malesTextEditingController.clear();
        femalesTextEditingController.clear();
        chicksTextEditingController.clear();
      }
    else
      {
        Fluttertoast.showToast(msg: "Fill in your data");
      }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveInfo,
        label: Text("Save"),
        icon: Icon(Icons.save),
      ),
      appBar: AppBar(
        title: Text(
            widget.category == "All"? "Add Data": widget.category
        ),
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(10.0),
              child: TextFormField(
                controller: nameTextEditingController,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        width: 1.0,
                      )
                  ),
                  focusColor: Theme.of(context).primaryColor,
                  hintText: "Name",
                  labelText: "Name",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(10.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: malesTextEditingController,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        width: 1.0,
                      )
                  ),
                  focusColor: Theme.of(context).primaryColor,
                  hintText: "Males",
                  labelText: "Males",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(10.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: femalesTextEditingController,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        width: 1.0,
                      )
                  ),
                  focusColor: Theme.of(context).primaryColor,
                  hintText: "Females",
                  labelText: "Females",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(10.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: chicksTextEditingController,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        width: 1.0,
                      )
                  ),
                  focusColor: Theme.of(context).primaryColor,
                  hintText: "Chicks",
                  labelText: "Chicks",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
