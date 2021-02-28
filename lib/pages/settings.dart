import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String url = "https://play.google.com/store/apps/details?id=com.bivatec.poultry_farmers_app";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> GeneralSettings()));
                },
                child: Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("General", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> AboutApp()));
                },
                child: Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("About", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
              ),

              InkWell(
                onTap: () async {
                  if (await canLaunch(url)) {
                    await launch(
                      url,
                      universalLinksOnly: true,
                    );
                  } else {

                    Fluttertoast.showToast(msg: "Error opening: $url");
                    //throw 'There was a problem to open the url: $twitterUrl';
                  }
                },
                child: Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Recommended in Playstore", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About App"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Ornamental Poultry Farming Application System is a project work that is expected to help achieve an effective management for ornamental farmers."
            "The system is expected to succeed interms of dependability and sustainability. "
            "The need for the new system is to solve the limitations discovered in the previously existing applications and system.",
            //overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}



class GeneralSettings extends StatefulWidget {
  @override
  _GeneralSettingsState createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {

  bool isSwitched = false;
  bool notifications = true;

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
  }

  void changeColor() {
    DynamicTheme.of(context).setThemeData(new ThemeData(
        primaryColor: Theme.of(context).primaryColor == Colors.indigo? Colors.red: Colors.indigo
    ));
  }

  void toggleNotificationSwitch(bool value) {

    if(notifications == false)
    {
      setState(() {
        notifications = true;
      });
    }
    else
    {
      setState(() {
        notifications = false;
      });
    }
  }

  void toggleSwitch(bool value) {

    if(isSwitched == false)
    {
      setState(() {
        isSwitched = true;
      });
    }
    else
    {
      setState(() {
        isSwitched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = DynamicTheme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("General Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              title: Text("Enable notifications"),
              trailing: Switch(
                activeColor: Colors.pink,
                inactiveThumbColor: Theme.of(context).scaffoldBackgroundColor,
                inactiveTrackColor: Colors.grey,
                value: notifications,
                onChanged: (value) {
                  toggleNotificationSwitch(value);
                },
              ),
            ),
            ListTile(
              title: Text("Enable crash Login"),
              trailing: Switch(
                activeColor: Colors.pink,
                inactiveThumbColor: Theme.of(context).scaffoldBackgroundColor,
                inactiveTrackColor: Colors.grey,
                value: isSwitched,
                onChanged: (value) {
                  toggleSwitch(value);
                },
              ),
            ),
            SizedBox(height: 10.0,),
            ListTile(
              title: Text("Dark Mode"),
              trailing: Switch(
                activeColor: Colors.pink,
                inactiveThumbColor: Theme.of(context).scaffoldBackgroundColor,
                inactiveTrackColor: Colors.grey,
                value: isDark,
                onChanged: (value) {
                  changeBrightness();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

