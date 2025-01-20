import 'package:flutter/material.dart';
import 'package:mobile/screens/complaint.dart';
import 'package:mobile/screens/manage_babies.dart';
import 'package:mobile/screens/view_daycare.dart';
import 'package:mobile/screens/view_facilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Facilities()));
                  },
                  child: Text('facilities'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Daycare()));
                  },
                  child: Text('Daycare'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ManageBabies()));
                  },
                  child: Text('Manage Babies'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Complaint()));
                  },
                  child: Text('Send complaint'),
                ),
              ],
            )),
      ),
    );
  }
}
