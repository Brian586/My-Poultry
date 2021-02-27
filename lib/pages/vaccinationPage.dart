import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:my_poultry/widgets/customTextField.dart';
import 'package:table_calendar/table_calendar.dart';


class VaccinationPage extends StatefulWidget {
  @override
  _VaccinationPageState createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {

  TextEditingController controller = TextEditingController();
  TextEditingController nameController = TextEditingController();
  CalendarController _calendarController;
  List selectedEvents = [];

  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      selectedEvents = events;
    });

    print(day);
    print(events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vaccination Page"),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextField(
              controller: nameController,
              data: Icons.edit,
              hintText: "Name",
              isObscure: false,
            ),
            SizedBox(height: 10.0,),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItem: true,
                items: [
                  "Chicken",
                  "Quails",
                  "Ducks",
                  "Geese",
                  "Guinea Fowls",
                  "Musk Ducks",
                  "Turkeys",
                  "Pigeons"
                ],
                label: "Bird Species",
                hint: "Bird Species",
                //popupItemDisabled: (String s) => s.startsWith('I'),
                onChanged: (v) {
                  setState(() {
                    controller.text = v;
                  });
                },
                //selectedItem: "Brazil"
              ),
            ),
            SizedBox(height: 10.0,),
            Text("Hatching", style: TextStyle(fontWeight: FontWeight.bold),),
            TableCalendar(
              calendarController: _calendarController,
              onDaySelected: _onDaySelected,
            ),
            SizedBox(height: 20.0,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FlatButton(
                splashColor: Colors.pinkAccent,
                onPressed: () {},
                color: Colors.pinkAccent.withOpacity(0.4),
                child: Container(
                  height: 50.0,
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: Text("Vaccination", style: TextStyle(color: Colors.white),))),
              ),
            ),
            SizedBox(height: 20.0,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FlatButton(
                onPressed: () {},
                color: Colors.pink,
                child: Container(
                    height: 40.0,
                    child: Center(child: Text("Save", style: TextStyle(color: Colors.white),))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
