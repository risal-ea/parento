import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/components/bottom_nav_bar.dart';
import 'package:mobile/components/reusable_card.dart';
import 'package:mobile/screens/baby_details.dart';
import 'package:mobile/screens/view_daycare.dart';
import 'package:mobile/screens/complaint.dart';
import 'package:mobile/screens/view_meetings.dart';
import 'package:mobile/screens/parent_profile.dart';
import 'package:mobile/bottom_sheet/baby_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> activities = []; // Updated to dynamic for flexibility
  int _selectedIndex = 0;
  String selectedBabyPhoto = "";
  String selectedBabyId = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateSelectedBaby(String newPhoto, String babyId) {
    setState(() {
      selectedBabyPhoto = newPhoto;
      selectedBabyId = babyId;
      activities.clear();
    });
    fetchData(); // Fetch data again when baby is updated
  }

  Future<void> fetchData() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString("login_id") ?? "";
      String ip = sh.getString("url") ?? "";
      String url = "$ip/home";

      print("Stored login_id: $login_id"); // Log the login_id
      print("Stored URL: $url"); // Log the URL

      print("Sending request to: $url"); // Log the URL
      print("Request body: login_id=$login_id, baby_id=$selectedBabyId"); // Log the request body

      var response = await http.post(
        Uri.parse(url),
        body: {"login_id": login_id, "baby_id": selectedBabyId},
      );

      print("Response status code: ${response.statusCode}"); // Log the status code
      print("Response body: ${response.body}"); // Log the response body

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        var arr = jsonData['data'] as List;

        setState(() {
          activities = arr.map<Map<String, dynamic>>((activity) {
            return {
              'Date': activity['date'].toString(),
              'Type': activity['activity_type'].toString(),
              'Description': activity['description'].toString(),
              'StartTime': activity['start_time'].toString(),
              'EndTime': activity['end_time'].toString(),
            };
          }).toList();
        });

        print("Activities fetched: ${activities.length}"); // Log the number of activities
      } else {
        print("Failed to fetch data: ${jsonData['message']}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // String calculateTotalSleepDuration() {
  //   double totalSleepHours = 0.0;
  //   for (var activity in activities) {
  //     if (activity['Type'] == 'Sleeping') {
  //       String startTime = activity['StartTime'] ?? "";
  //       String endTime = activity['EndTime'] ?? "";
  //       try {
  //         DateTime start = DateTime.parse("2024-01-01 $startTime");
  //         DateTime end = DateTime.parse("2024-01-01 $endTime");
  //
  //         if (end.isBefore(start)) {
  //           end = end.add(Duration(days: 1));
  //         }
  //
  //         Duration sleepDuration = end.difference(start);
  //         totalSleepHours += sleepDuration.inMinutes / 60.0;
  //       } catch (e) {
  //         print("Error parsing sleep time: $e");
  //       }
  //     }
  //   }
  //   return totalSleepHours > 0 ? "${totalSleepHours.toStringAsFixed(1)} hrs" : "N/A";
  // }

  String calculateDuration(String activityType) {
    double totalHours = 0.0;
    for (var activity in activities) {
      if (activity['Type'] == activityType) {
        String startTime = activity['StartTime'] ?? "";
        String endTime = activity['EndTime'] ?? "";
        try {
          DateTime start = DateTime.parse("2024-01-01 $startTime");
          DateTime end = DateTime.parse("2024-01-01 $endTime");
          if (end.isBefore(start)) {
            end = end.add(Duration(days: 1));
          }
          Duration duration = end.difference(start);
          totalHours += duration.inMinutes / 60.0;
        } catch (e) {
          print("Error parsing $activityType time: $e");
        }
      }
    }
    return totalHours > 0 ? "${totalHours.toStringAsFixed(1)} hrs" : "N/A";
  }


  Map<String, dynamic>? getLatestActivity() {
    if (activities.isNotEmpty) {
      return activities.first;
    }
    return null;
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

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? latestActivity = getLatestActivity();

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
            GestureDetector(
              onTap: () {
                if (selectedBabyId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BabyDetails(babyId: selectedBabyId)),
                  );
                }
              },
              child: BabySelection(
                onBabySelected: updateSelectedBaby,
              ),
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
                                    Icon(Icons.bedtime,
                                        size: 40, color: Colors.blue),
                                    const SizedBox(width: 5),
                                    Text("Sleep ${calculateDuration('Sleeping')}",
                                        style: TextStyle(fontSize: 16)),
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
                                  Icon(Icons.restaurant,
                                      size: 40, color: Colors.orange),
                                  const SizedBox(width: 5),
                                  Text("Eat ${calculateDuration("Playing")}",
                                      style: TextStyle(fontSize: 16)),
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
                              Icon(Icons.menu_book,
                                  size: 40, color: Colors.green),
                              const SizedBox(height: 5),
                              Text("Play ${calculateDuration("Studying")}", style: TextStyle(fontSize: 16)),
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
                  const Text("Latest Activity",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text("See all",
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (activities.isNotEmpty)
                ReusableCard(
                  colour: Colors.white,
                  cardChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var activity in activities.take(4)) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity['Type'] ?? "Activity",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    activity['Description'] ?? "",
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    activity['Date'] ?? "",
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                  ),
                                  Text(
                                    "${activity['StartTime'] ?? ""} - ${activity['EndTime'] ?? ""}",
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (activity != activities.take(4).last)
                          Divider(color: Colors.grey.shade300, thickness: 0.8),
                      ],
                    ],
                  ),
                  onPress: () {},
                ),
              const SizedBox(height: 20),
              buildButton(context, "View Daycare", Daycare()),
              buildButton(context, "Send Complaint", Complaint()),
              buildButton(context, "View Meetings", ViewMeetings()),
              buildButton(context, "Parent Profile", ParentProfile()),
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
}

