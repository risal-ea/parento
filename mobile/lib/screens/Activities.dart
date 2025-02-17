import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Activities extends StatefulWidget {
  const Activities({super.key});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  List<Map<String, String>> activities = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    load(); // Fetch data whenever dependencies change
  }

  Future<void> load() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString('login_id') ?? '';
      String ip = sh.getString("url") ?? "";
      String url = "$ip/Activities";

      var response = await http.post(Uri.parse(url), body: {'lid': login_id});
      var jsonData = json.decode(response.body);
      print(jsonData);

      if (jsonData['status'] == 'success') {
        var arr = jsonData['data'] as List;

        setState(() {
          activities = arr.map<Map<String, String>>((activity) {
            return {
              'Date': activity['date'].toString(),
              'Type': activity['activity_type'].toString(),
              'Description': activity['description'].toString(),
              'Start Time': activity['start_time'].toString(), // Fixed typo
              'End Time': activity['end_time'].toString(),
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Baby Activities"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: activities.isEmpty
            ? const Center(
          child: Text(
            "No activities found.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            var activity = activities[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🗓 Date: ${activity['Date']}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "📌 Type: ${activity['Type']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "📝 Description: ${activity['Description']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "⏰ Start Time: ${activity['Start Time']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "⏳ End Time: ${activity['End Time']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
