import 'package:flutter/material.dart';
import 'package:mobile/screens/baby_details.dart';
import 'package:mobile/screens/complaint.dart';
import 'package:mobile/screens/feedback.dart';
import 'package:mobile/screens/manage_babies.dart';
import 'package:mobile/screens/view_daycare.dart';
import 'package:mobile/screens/view_facilities.dart';
import 'package:mobile/screens/view_meetings.dart';
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
                        MaterialPageRoute(builder: (context) => ViewFacilities()));
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ViewMeetings()));
                  },
                  child: Text('View meetings'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SendFeedback()));
                  },
                  child: Text('Send feedback'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => BabyDetails()));
                  },
                  child: Text('Baby details'),
                ),
              ],
            )),
      ),
    );
  }
}
