import 'package:flutter/material.dart';
import 'package:mobile/components/reusable_card.dart';
import 'package:mobile/screens/activities.dart';
import 'package:mobile/screens/baby_profile.dart';
import 'package:mobile/screens/complaint.dart';
import 'package:mobile/screens/feedback.dart';
import 'package:mobile/screens/manage_babies.dart';
import 'package:mobile/screens/view_daycare.dart';
import 'package:mobile/screens/view_facilities.dart';
import 'package:mobile/screens/view_meetings.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              "Parento",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ClipOval(
              child: Image.asset(
                "images/baby1.jpg",
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0), // Global margin for the entire layout
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // **Activity Cards Row**
            SizedBox(
              height: 170,
              child: Row(
                children: [
                  // **First Column (Sleep + Eat)**
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: SizedBox(
                            height: 80, // Set fixed height to keep uniformity
                            child: ReusableCard(
                              colour: Colors.blue.shade100,
                              onPress: () {},
                              cardChild: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bedtime, size: 40, color: Colors.blue),
                                  const SizedBox(width: 5),
                                  Text("Sleep 11hr", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 80, // Set fixed height
                          child: ReusableCard(
                            colour: Colors.orange.shade100,
                            onPress: () {},
                            cardChild: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant, size: 40, color: Colors.orange),
                                const SizedBox(width: 5),
                                Text("Eat 3x", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10), // Ensures spacing between columns
                  // **Second Column (Play)**
                  Expanded(
                    child: SizedBox(
                      height: 170, // Matches the height of the first column
                      child: ReusableCard(
                        colour: Colors.green.shade100,
                        onPress: () {},
                        cardChild: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 40, color: Colors.green),
                            const SizedBox(height: 5),
                            Text("Play 2hr", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // **Latest Activity Section**
            Row(
              children: [
                const Text("Latest Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text("See all", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // **Buttons**
            Expanded(
              child: ListView(
                children: [
                  buildButton(context, "Facilities", ViewFacilities()),
                  buildButton(context, "Daycare", Daycare()),
                  buildButton(context, "Manage Babies", ManageBabies()),
                  buildButton(context, "Send Complaint", Complaint()),
                  buildButton(context, "View Meetings", ViewMeetings()),
                  buildButton(context, "Send Feedback", SendFeedback()),
                  buildButton(context, "Baby Profile", BabyProfile()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // **Helper Function to Create Buttons**
  Widget buildButton(BuildContext context, String text, Widget destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        },
        child: Text(text),
      ),
    );
  }
}
