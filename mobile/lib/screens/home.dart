import 'package:flutter/material.dart';
import 'package:mobile/components/bottom_nav_bar.dart';
import 'package:mobile/components/reusable_card.dart';
import 'package:mobile/screens/activities.dart';
import 'package:mobile/screens/baby_profile.dart';
import 'package:mobile/screens/manage_babies.dart';
import 'package:mobile/screens/view_daycare.dart';
import 'package:mobile/screens/view_facilities.dart';
import 'package:mobile/screens/view_meetings.dart';
import 'package:mobile/screens/complaint.dart';
import 'package:mobile/screens/feedback.dart';
import 'package:mobile/bottom_sheet/baby_selection.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // Track selected tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text(
              "Parento",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            BabySelection(
              onBabySelected: (String newPhoto) {
                setState(() {
                  // selectedBabyPhoto = newPhoto;
                });
              },
            ),

          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 170,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SizedBox(
                              height: 80,
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
                            height: 80,
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 170,
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
              SizedBox(
                height: 250,
                child: ReusableCard(
                  colour: Colors.white,
                  cardChild: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sleeping", style: TextStyle(
                                  fontSize: 18,
                                fontWeight: FontWeight.w500
                              ),),
                              Text("afternoon nap", style: TextStyle(
                                  fontSize: 13
                              ),),
                            ],
                          ),
                          const Spacer(),
                          Text("now"),
                        ],
                      ),
                      Divider(color: Colors.grey, thickness: 0.5),
                    ],
                  ),
                  onPress: () {},
                ),
              ),
              const SizedBox(height: 20),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  buildButton(context, "Facilities", ViewFacilities()),
                  buildButton(context, "Daycare", Daycare()),
                  buildButton(context, "Manage Babies", ManageBabies()),
                  buildButton(context, "Send Complaint", Complaint()),
                  buildButton(context, "View Meetings", ViewMeetings()),
                  // buildButton(context, "Baby Profile", BabyProfile()),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, Widget destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destination));
        },
        child: Text(text),
      ),
    );
  }
}
