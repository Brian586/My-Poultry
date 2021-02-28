import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_poultry/Config/config.dart';
import 'package:my_poultry/DialogBox/groupInfo.dart';
import 'package:my_poultry/models/groupModel.dart';
import 'package:my_poultry/widgets/customTextField.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';


class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {

  bool loading = false;
  String city;
  String country;
  Future futureGroupList;

  @override
  void initState() {
    super.initState();

    fetchGroups();
  }

  _determinePosition() async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permantly denied, we cannot request permissions.');
      }
      else if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {

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
        city = cityAddress;
        country = countryAddress;
      });
    }
  }

  Future<void> fetchGroups() async {
    setState(() {
      loading = true;
    });

    await _determinePosition();

    Future groups = Firestore.instance.collection("groups")
        .where("city", isEqualTo: city).where("country", isEqualTo: country)
        //.where("members", arrayContains: MyPoultry.sharedPreferences.getString(MyPoultry.userUID))
        .orderBy("timestamp", descending: true).getDocuments();



    setState(() {
      loading = false;
      futureGroupList = groups;
    });

  }
  
  viewDetails(BuildContext context, MyGroup group) {
    return showDialog(
      context: context,
      builder: (c) {
        return GroupInfo(group: group,);
      }
    );
  }
  
  displayData() {
    return FutureBuilder<QuerySnapshot>(
      future: futureGroupList,
      builder: (BuildContext context, snapshot) {
        if(!snapshot.hasData)
          {
            return circularProgress();
          }
        else
          {
            List<MyGroup> groupsList = [];
            snapshot.data.documents.forEach((element) {
              MyGroup group = MyGroup.fromDocument(element);
              groupsList.add(group);
            });

            if(groupsList.length == 0)
              {
                return Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("No Groups"),
                    RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)
                        ),
                        color: Colors.pink,
                        onPressed: fetchGroups,
                        elevation: 5.0,
                        icon: Icon(Icons.refresh_rounded, color: Colors.white,),
                        label: Text("Refresh", style: TextStyle(color: Colors.white),)
                    )
                  ],
                ),);
              }
            else
              {
                return ListView.builder(
                  itemCount: groupsList.length,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    MyGroup group = groupsList[index];

                    return ListTile(
                      title: Text(group.name, style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text(group.type),
                      onTap: () => viewDetails(context, group),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Groups"),
      ),
      body: loading ? circularProgress() : displayData(),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.group_add, color: Colors.white,),
        label: Text("Create Group"),
        onPressed: () {
          Route route = MaterialPageRoute(builder: (context)=> AddGroup(city: city, country: country,));
          Navigator.push(context, route);
        },
      ),
    );
  }
}


class AddGroup extends StatefulWidget {

  final String city;
  final String country;

  AddGroup({this.country, this.city});

  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {

  TextEditingController name = TextEditingController();
  TextEditingController type = TextEditingController();
  TextEditingController link = TextEditingController();
  bool loading = false;

  saveInfo() async {
    setState(() {
      loading = true;
    });

    String userId = MyPoultry.sharedPreferences.getString(MyPoultry.userUID);

    await Firestore.instance.collection("groups").add({
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "name": name.text.trim(),
      "type": type.text.trim(),
      "link": link.text.trim(),
      "city": widget.city,
      "country": widget.country,
      "members": [userId]
    }).then((value) => Fluttertoast.showToast(msg: "Saved ${name.text.trim()} successfully!"));

    setState(() {
      loading = false;
      name.text = "";
      type.text = "";
      link.text = "";
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              controller: name,
              isObscure: false,
              hintText: "Group Name",
              data: Icons.people,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItem: true,
                items: [
                  "LinkedIn",
                  "WhatsApp",
                  "Instagram"
                ],
                label: "Group Type",
                hint: "Group Type",
                //popupItemDisabled: (String s) => s.startsWith('I'),
                onChanged: (v) {
                  setState(() {
                    type.text = v;
                  });
                },
                //selectedItem: "Brazil"
              ),
            ),
            CustomTextField(
              controller: link,
              isObscure: false,
              hintText: "Link",
              data: Icons.link,
            ),
            SizedBox(
              height: 30.0,
            ),
            RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)
                ),
                color: Colors.pink,
                onPressed: () {
                  name.text.isNotEmpty && type.text.isNotEmpty && link.text.isNotEmpty
                      ? saveInfo()
                      : Fluttertoast.showToast(msg: "Fill the required Information");
                },
                elevation: 5.0,
                icon: Icon(Icons.done, color: Colors.white,),
                label: Text("Done", style: TextStyle(color: Colors.white),)
            )
          ],
        ),
      ),
    );
  }
}
