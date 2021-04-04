import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_poultry/Admin/myProducts.dart';
import 'package:my_poultry/DialogBox/errorDialog.dart';
import 'package:my_poultry/pages/agrovetProducts.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';

import 'adminChatHome.dart';
import 'adminShiftOrders.dart';


class UploadPage extends StatefulWidget
{

  final String name;
  final String phone;
  final String userID;

  UploadPage({this.name, this.phone, this.userID});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>
{
  bool get wantKeepAlive => true;
  File file;
  bool loading= false;
  final picker = ImagePicker();
  TextEditingController _descriptionTextEditingController = TextEditingController();
  TextEditingController _priceTextEditingController = TextEditingController();
  TextEditingController _categoryTextEditingController = TextEditingController();
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _shortInfoTextEditingController = TextEditingController();
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;
  String city;
  String country;


  @override
  void initState() {
    super.initState();

    _determinePosition();
  }

  _determinePosition() async {

    setState(() {
      uploading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {

        setState(() {
          uploading = false;
        });

        return Future.error(
            'Location permissions are permantly denied, we cannot request permissions.');
      }
      else if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {

          setState(() {
            uploading = false;
          });

          return Future.error(
              'Location permissions are denied (actual value: $permission).');
        }
      }
      else
      {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        Placemark mPlaceMark = placeMarks[0];
        String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, '
            '${mPlaceMark.subLocality} ${mPlaceMark.locality}, '
            '${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, '
            '${mPlaceMark.postalCode} ${mPlaceMark.country}';
        String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
        String cityAddress = '${mPlaceMark.locality}';
        String countryAddress = '${mPlaceMark.country}';

        print(specificAddress);
        setState(() {
          uploading = false;
          city = cityAddress;
          country = countryAddress;
        });
      }

      //return Future.error('Location services are disabled.');
    }
    else
    {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark mPlaceMark = placeMarks[0];
      String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, '
          '${mPlaceMark.subLocality} ${mPlaceMark.locality}, '
          '${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, '
          '${mPlaceMark.postalCode} ${mPlaceMark.country}';
      String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
      String cityAddress = '${mPlaceMark.locality}';
      String countryAddress = '${mPlaceMark.country}';

      print(specificAddress);
      setState(() {
        uploading = false;
        city = cityAddress;
        country = countryAddress;
      });
    }
  }


  displayAdminHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Home"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Route route = MaterialPageRoute(builder: (context)=> AgrovetProducts());
            Navigator.pushReplacement(context, route);
          },
        ),
        centerTitle: true,
      ),
      body: getAdminHomeScreenBody(),
    );
  }

  getAdminHomeScreenBody() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notifications_active_outlined, color: Colors.pink,),
            title: Text("Messages", style: GoogleFonts.fredokaOne( fontSize: 18.0),),
            onTap: () {
              Route route = MaterialPageRoute(builder: (context)=> AdminChatHome(userID: widget.userID));
              Navigator.push(context, route);
            },
          ),
          ListTile(
            leading: Icon(Icons.shop_two_outlined, color: Colors.pink,),
            title: Text("Ordered Products", style: GoogleFonts.fredokaOne(fontSize: 18.0),),
            subtitle: Text("See people who ordered your products", style: TextStyle(color: Colors.grey, fontSize: 15.0),),
            onTap: () {
              Route route = MaterialPageRoute(builder: (context)=> AdminShiftOrders(
                userID: widget.userID,
                phone: widget.phone,
                name: widget.name,
              ));
              Navigator.push(context, route);
            },
          ),
          ListTile(
            leading: Icon(Icons.cloud_upload_outlined, color: Colors.pink,),
            title: Text("Upload Products", style: GoogleFonts.fredokaOne(fontSize: 18.0),),
            onTap: ()=> takeImage(context),
          ),
          ListTile(
            leading: Icon(Icons.my_library_books_outlined, color: Colors.pink,),
            title: Text("View My Products", style: GoogleFonts.fredokaOne(fontSize: 18.0),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> MyProducts(userId: widget.userID,)));
            },
          ),
        ],
      ),
    );
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (c) {
        return SimpleDialog(
          title: Text("Item Image", textAlign: TextAlign.center, style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),),
          children: [
            SimpleDialogOption(
              child: Text("Capture with Camera", style: TextStyle(color: Colors.black),),
              onPressed: capturePhotoWithCamera,
            ),
            SimpleDialogOption(
              child: Text("Select from Gallery", style: TextStyle(color: Colors.black),),
              onPressed: pickPhotoFromGallery,
            ),
            SimpleDialogOption(
              child: Text("Cancel", style: TextStyle(color: Colors.black),),
              onPressed: () {Navigator.pop(context);},
            )
          ],
        );
      }
    );
  }

  pickPhotoFromGallery() async {
    Navigator.pop(context);

    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      file = imageFile;
    });
  }

  capturePhotoWithCamera() async {
    Navigator.pop(context);

    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 680.0, maxWidth: 970.0);

    setState(() {
      file = imageFile;
    });
  }


  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: clearFormInfo,
        ),
        title: Text("New Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.0),),
        centerTitle: true,
        actions: [
          // FlatButton(
          //   child: Text("Add", style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),),
          //   onPressed: uploading ? null : () => uploadImageAndSaveItemInfo()
          // )
        ],
      ),
      body: uploading ? circularProgress() : ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            height: 300.0,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.contain
                    )
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12.0)),
          ListTile(
            leading: Icon(Icons.perm_device_info, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.pink,
                style: TextStyle(color: Colors.black),
                controller: _shortInfoTextEditingController,
                decoration: InputDecoration(
                  hintText: "Short Info",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),

          ListTile(
            leading: Icon(Icons.perm_device_info, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.pink,
                style: TextStyle(color: Colors.black),
                controller: _titleTextEditingController,
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),

          ListTile(
            leading: Icon(Icons.edit, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.pink,
                maxLines: null,
                style: TextStyle(color: Colors.black),
                controller: _descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),

          ListTile(
            leading: Icon(Icons.attach_money_rounded, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.pink,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: _priceTextEditingController,
                decoration: InputDecoration(
                  hintText: "Price",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: DropdownSearch<String>(
              mode: Mode.MENU,
              showSelectedItem: true,
              items: [
                "Medicine",
                "Feeds",
                "Feeding Equipment",
                "Housing Equipment",
                "Storage Equipment"
              ],
              label: "Category",
              hint: "Category",
              //popupItemDisabled: (String s) => s.startsWith('I'),
              onChanged: (v) {
                setState(() {
                  _categoryTextEditingController.text = v;
                });
              },
              //selectedItem: "Brazil"
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 40,
                //width: 180,
                child: RaisedButton.icon(
                  onPressed: uploading ? null : () => uploadImageAndSaveItemInfo(),
                  color: Colors.pink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)
                  ),
                  icon: Icon(Icons.upload_outlined, color: Colors.white,),
                  label: Text("Upload", style: GoogleFonts.fredokaOne(color: Colors.white, fontSize: 17.0),),
                  elevation: 5.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<String> uploadItemImage(mFileImage) async {
    final StorageReference storageReference = FirebaseStorage.instance.ref().child("Items");
    StorageUploadTask uploadTask = storageReference.child("product_$productId.jpg").putFile(mFileImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadImageAndSaveItemInfo() async {
    setState(() {
      uploading = true;
    });

    String imageDownloadUrl = await uploadItemImage(file);

    if(_shortInfoTextEditingController.text.isNotEmpty
        && _descriptionTextEditingController.text.isNotEmpty
        && _priceTextEditingController.text.isNotEmpty && _categoryTextEditingController.text.isNotEmpty
        && _titleTextEditingController.text.isNotEmpty
        && city.isNotEmpty && country.isNotEmpty)
      {
        saveItemInfo(imageDownloadUrl, productId);
      }
    else
      {
        setState(() {
          uploading = false;
        });

        showDialog(
            context: context,
            builder: (c) {
              return ErrorAlertDialog(message: "Missing information",);
            }
        );
      }

  }

  Future<String> uploadPhoto2(File mImageFile, String type) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final StorageReference storageReference = FirebaseStorage.instance.ref().child("Items");
    StorageUploadTask mStorageUploadTask = storageReference.child("${fileName}_$productId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  saveItemInfo(String downloadUrl, String postId) async
  {
    final itemsRef = Firestore.instance.collection("products");
    await itemsRef.document(productId).setData({
      "shortInfo": _shortInfoTextEditingController.text.trim(),
      "longDescription": _descriptionTextEditingController.text.trim(),
      "price": int.parse(_priceTextEditingController.text.trim()),
      "publishedDate": DateTime.now().millisecondsSinceEpoch,
      "status": "available",
      "searchKey": _titleTextEditingController.text.trim().toLowerCase(),
      "category": _categoryTextEditingController.text,
      "productId": productId,
      "thumbnailUrl": downloadUrl,
      "title": _titleTextEditingController.text.trim(),
      "publisher": widget.name,
      "publisherID": widget.userID,
      "phone": widget.phone,
      "city": city,
      "country": country,
    });

    setState(() {
      file = null;
      uploading = false;
      productId= DateTime.now().millisecondsSinceEpoch.toString();
      _descriptionTextEditingController.clear();
      _titleTextEditingController.clear();
      _categoryTextEditingController.clear();
      _shortInfoTextEditingController.clear();
      _priceTextEditingController.clear();
    });
  }

  clearFormInfo() {
    setState(() {
      file = null;
    });

    _descriptionTextEditingController.clear();
    _priceTextEditingController.clear();
    _categoryTextEditingController.clear();
    _titleTextEditingController.clear();
    _shortInfoTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? displayAdminHomeScreen() : displayUploadFormScreen();
  }
}


class AddImage extends StatelessWidget {

  final Function onPressed;
  final IconData iconData;

  AddImage({@required this.onPressed, this.iconData});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
            height: 90.0,
            width: 110.0,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Center(
              child: Icon(iconData, color: Colors.grey, size: 30.0,),
            )
        ),
      ),
    );
  }
}

