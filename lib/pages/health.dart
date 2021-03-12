import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:my_poultry/models/healthModel.dart';
import 'package:my_poultry/widgets/loadingWidget.dart';


class Health extends StatefulWidget {
  @override
  _HealthState createState() => _HealthState();
}

class _HealthState extends State<Health> {

  bool loading = false;
  Future futureVaccinations;
  Future futureMedications;


  @override
  void initState() {
    super.initState();

    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
    });

    Future vaccinations = Firestore.instance.collection("vaccines").getDocuments();
    Future medication = Firestore.instance.collection("medication").getDocuments();

    setState(() {
      loading = false;
      futureMedications = medication;
      futureVaccinations = vaccinations;
    });
  }

  vaccination() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> AddVaccination()));
        },
        label: Text("Vaccination", style: TextStyle(color: Colors.white),),
        icon: Icon(Icons.add, color: Colors.white,),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: futureVaccinations,
        builder: (BuildContext context, snapshot) {
          if(!snapshot.hasData)
            {
              return circularProgress();
            }
          else
            {
              List<Vaccination> vaccinations = [];
              snapshot.data.documents.forEach((element) {
                Vaccination vaccination = Vaccination.fromDocument(element);
                vaccinations.add(vaccination);
              });

              if(vaccinations.length == 0)
                {
                  return Center(child: Text("No Vaccinations"),);
                }
              else
                {
                  return ListView.builder(
                    itemCount: vaccinations.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      Vaccination vaccination = vaccinations[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(color: Colors.black38, offset: Offset(2.0, 2.0), blurRadius: 6.0)
                            ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Disease: ${vaccination.disease}"),
                                Text("Vaccine: ${vaccination.vaccineName}"),
                                Text("Type: ${vaccination.type}"),
                                Text("Date: "+ DateFormat.yMMMMEEEEd().format(DateTime.fromMillisecondsSinceEpoch(vaccination.dateTime))),
                                Text("Personnel: ${vaccination.personnel}"),
                                Text("No. birds: ${vaccination.number.toString()}"),
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
    );
  }

  medication() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> AddMedication()));
        },
        label: Text("medication", style: TextStyle(color: Colors.white),),
        icon: Icon(Icons.add, color: Colors.white,),
      ),
      body:FutureBuilder<QuerySnapshot>(
        future: futureMedications,
        builder: (BuildContext context, snapshot) {
          if(!snapshot.hasData)
          {
            return circularProgress();
          }
          else
          {
            List<Medication> medications = [];
            snapshot.data.documents.forEach((element) {
              Medication medication = Medication.fromDocument(element);
              medications.add(medication);
            });

            if(medications.length == 0)
            {
              return Center(child: Text("No Medication"),);
            }
            else
            {
              return ListView.builder(
                itemCount: medications.length,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  Medication medication = medications[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(color: Colors.black38, offset: Offset(2.0, -2.0), blurRadius: 6.0)
                          ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Disease: ${medication.disease}"),
                            Text("Medicine: ${medication.medicineName}"),
                            Text("Type: ${medication.type}"),
                            Text("Date: "+ DateFormat.yMMMMEEEEd().format(DateTime.fromMillisecondsSinceEpoch(medication.dateTime))),
                            Text("Personnel: ${medication.personnel}"),
                            Text("No. birds: ${medication.number.toString()}"),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Health"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_hospital), text: "Vaccinations",),
              Tab(icon: Icon(Icons.medical_services_outlined), text: "Medication",),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            vaccination(),
            medication()
          ],
        ),
      ),
    );
  }
}

class AddVaccination extends StatefulWidget {
  @override
  _AddVaccinationState createState() => _AddVaccinationState();
}

class _AddVaccinationState extends State<AddVaccination> {

  TextEditingController type = TextEditingController();
  TextEditingController disease = TextEditingController();
  TextEditingController vaccineName = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController vaccinatedBy = TextEditingController();
  TextEditingController notes = TextEditingController();
  bool loading = false;
  DateTime dateTime;
  TimeOfDay selectedTime = TimeOfDay.now();

  saveInfo() async {
    setState(() {
      loading = true;
    });

    await Firestore.instance.collection("vaccines").add({
      "type": type.text,
      "disease": disease.text,
      "vaccineName": vaccineName.text.trim(),
      "number": int.parse(number.text.trim()),
      "vaccinatedBy": vaccinatedBy.text.trim(),
      "notes":  notes.text.isNotEmpty ? notes.text : "",
      "dateTime": dateTime.millisecondsSinceEpoch
    }).then((_) {
      Fluttertoast.showToast(msg: "Saved Successfully");
    });


    setState(() {
      loading = false;
      type.clear();
      disease.clear();
      vaccineName.clear();
      number.clear();
      vaccinatedBy.clear();
      notes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vaccination"),
        actions: [
          IconButton(
            icon: Icon(Icons.check_box, color: Colors.white70,),
            onPressed: () {
              type.text.isNotEmpty
                  && disease.text.isNotEmpty
                  && vaccineName.text.isNotEmpty
                  && number.text.isNotEmpty
                  && vaccinatedBy.text.isNotEmpty
                  ? saveInfo()
                  : Fluttertoast.showToast(msg: "Fill in required fields");
            },
          )
        ],
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItem: true,
                items: [
                  "Whole Farm",
                  "Flock"
                ],
                label: "Involved birds",
                hint: "Involved birds",
                //popupItemDisabled: (String s) => s.startsWith('I'),
                onChanged: (v) {
                  setState(() {
                   type.text = v;
                  });
                },
                //selectedItem: "Brazil"
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItem: true,
                items: [
                  "Fowl Cholera",
                  "Fowl Pox",
                  "IBD (Gumboro)",
                  "Marek's",
                  "Newcastle",
                  "Ranikhet"
                ],
                label: "Select Disease",
                hint: "Select Disease",
                //popupItemDisabled: (String s) => s.startsWith('I'),
                onChanged: (v) {
                  setState(() {
                    disease.text = v;
                  });
                },
                //selectedItem: "Brazil"
              ),
            ),
            MyTextField(
              controller: vaccineName,
              hintText: "Vaccine Name",
              keyboardType: TextInputType.text,
            ),
            MyTextField(
              controller: number,
              hintText: "Number of Birds",
              keyboardType: TextInputType.number,
            ),
            Container(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    dateTime = newDateTime;
                  });
                  print(newDateTime);
                },
              ),
            ),
            MyTextField(
              controller: vaccinatedBy,
              hintText: "Vaccinated By",
              keyboardType: TextInputType.text,
            ),
            MyTextField(
              controller: notes,
              hintText: "Notes",
              keyboardType: TextInputType.text,
            ),
          ],
        ),
      ),
    );
  }
}


class AddMedication extends StatefulWidget {
  @override
  _AddMedicationState createState() => _AddMedicationState();
}

class _AddMedicationState extends State<AddMedication> {

  TextEditingController type = TextEditingController();
  TextEditingController disease = TextEditingController();
  TextEditingController medicineName = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController medicatedBy = TextEditingController();
  TextEditingController notes = TextEditingController();
  bool loading = false;
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime dateTime;
  bool isKnown = false;

  saveInfo() async {
    setState(() {
      loading = true;
    });

      await Firestore.instance.collection("medication").add({
        "type": type.text,
        "disease": disease.text,
        "medicineName": medicineName.text.trim(),
        "number": int.parse(number.text.trim()),
        "medicatedBy": medicatedBy.text.trim(),
        "notes": notes.text.isNotEmpty ? notes.text : "",
        "dateTime": dateTime.millisecondsSinceEpoch
      }).then((_) {
        Fluttertoast.showToast(msg: "Saved Successfully");
      });

    setState(() {
      loading = false;
      type.clear();
      disease.clear();
      medicineName.clear();
      number.clear();
      medicatedBy.clear();
      notes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medication"),
        actions: [
          IconButton(
            icon: Icon(Icons.check_box, color: Colors.white70,),
            onPressed: () {
              type.text.isNotEmpty
                  && disease.text.isNotEmpty
                  && medicineName.text.isNotEmpty
                  && number.text.isNotEmpty
                  && medicatedBy.text.isNotEmpty
                  ? saveInfo()
                  : Fluttertoast.showToast(msg: "Fill in required fields");
            },
          )
        ],
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItem: true,
                items: [
                  "Whole Farm",
                  "Flock"
                ],
                label: "Involved birds",
                hint: "Involved birds",
                //popupItemDisabled: (String s) => s.startsWith('I'),
                onChanged: (v) {
                  setState(() {
                    type.text = v;
                  });
                },
                //selectedItem: "Brazil"
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItem: true,
                items: [
                  "Yes",
                  "No",
                ],
                label: "Is it for a known Disease?",
                hint: "Is it for a known Disease?",
                //popupItemDisabled: (String s) => s.startsWith('I'),
                onChanged: (v) {
                  if(v == "Yes")
                    {
                      setState(() {
                        isKnown = true;
                      });
                    }
                  else
                    {
                      setState(() {
                        isKnown = false;
                      });
                    }
                },
                //selectedItem: "Brazil"
              ),
            ),
            isKnown ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItem: true,
                items: [
                  "Fowl Cholera",
                  "Fowl Pox",
                  "IBD (Gumboro)",
                  "Marek's",
                  "Newcastle",
                  "Ranikhet"
                ],
                label: "Select Disease",
                hint: "Select Disease",
                //popupItemDisabled: (String s) => s.startsWith('I'),
                onChanged: (v) {
                  setState(() {
                    disease.text = v;
                  });
                },
                //selectedItem: "Brazil"
              ),
            ) : MyTextField(
              controller: disease,
              hintText: "Disease Name",
              keyboardType: TextInputType.text,
            ),
            MyTextField(
              controller: medicineName,
              hintText: "Medicine Name",
              keyboardType: TextInputType.text,
            ),
            MyTextField(
              controller: number,
              hintText: "Number of Birds",
              keyboardType: TextInputType.number,
            ),
            Container(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    dateTime = newDateTime;
                  });
                  print(newDateTime);
                },
              ),
            ),
            MyTextField(
              controller: medicatedBy,
              hintText: "Medicated By",
              keyboardType: TextInputType.text,
            ),
            MyTextField(
              controller: notes,
              hintText: "Notes",
              keyboardType: TextInputType.text,
            ),
          ],
        ),
      ),
    );
  }
}




class MyTextField extends StatelessWidget
{
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;



  MyTextField(
      {Key key, this.controller,this.hintText, this.keyboardType}
      ) : super(key: key);



  @override
  Widget build(BuildContext context)
  {
    return Container
      (
      decoration: BoxDecoration(
        // color: Colors.grey.withOpacity(0.3),
        // borderRadius: BorderRadius.circular(30.0),
      ),
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: null,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                width: 1.0,
              )
          ),
          focusColor: Theme.of(context).primaryColor,
          hintText: hintText,
          labelText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}


