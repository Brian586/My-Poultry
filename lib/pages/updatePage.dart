import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_poultry/models/productModel.dart';
import 'package:my_poultry/pages/health.dart';
import 'package:my_poultry/widgets/customTextField.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';


class UpdatePage extends StatefulWidget {

  final Product product;

  UpdatePage({this.product});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {

  TextEditingController shortInfo = TextEditingController();
  TextEditingController longDescription = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController title = TextEditingController();
  bool uploading = false;

  @override
  void initState() {
    super.initState();

    shortInfo.text = widget.product.shortInfo;
    longDescription.text = widget.product.longDescription;
    price.text = widget.product.price.toString();
    title.text = widget.product.title;
  }

  updateInfo() async {
    setState(() {
      uploading = true;
    });
    
    await Firestore.instance.collection("products")
        .document(widget.product.productId).updateData({
      "shortInfo": shortInfo.text.trim(),
      "longDescription": longDescription.text.trim(),
      "price": int.parse(price.text.trim()),
      "publishedDate": DateTime.now().millisecondsSinceEpoch,
      "title": title.text.trim(),
    }).then((value) => Fluttertoast.showToast(msg: "Updated Successfully"));
    
    setState(() {
      uploading = false;
    });
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Post"),
      ),
      body: uploading ? circularProgress() : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 300.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.product.thumbnailUrl),
                  fit: BoxFit.cover
                )
              ),
            ),
            SizedBox(height: 20.0,),
            MyTextField(
              controller: title,
              hintText: "Title",
              keyboardType: TextInputType.text,
            ),
            MyTextField(
              controller: shortInfo,
              hintText: "Short Info",
              keyboardType: TextInputType.text,
            ),
            MyTextField(
              controller: price,
              hintText: "Price",
              keyboardType: TextInputType.number,
            ),
            MyTextField(
              controller: longDescription,
              hintText: "Description",
              keyboardType: TextInputType.text,
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
                    onPressed: uploading ? null : () => updateInfo(),
                    color: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    icon: Icon(Icons.update, color: Colors.white,),
                    label: Text("Update", style: GoogleFonts.fredokaOne(color: Colors.white, fontSize: 17.0),),
                    elevation: 5.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 50.0,),
          ],
        ),
      ),
    );
  }
}
