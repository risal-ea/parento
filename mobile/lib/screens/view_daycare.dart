import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'daycare_details.dart'; // Import the details page

class Daycare extends StatefulWidget {
  const Daycare({Key? key}) : super(key: key);

  @override
  State<Daycare> createState() => _DaycareState();
}

class _DaycareState extends State<Daycare> {
  List<Map<String, String>> daycareList = []; // Stores daycare details
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    loadDaycares();
  }

  Future<void> loadDaycares() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String loginId = sh.getString('login_id') ?? '';
      String ip = sh.getString('url') ?? '';
      String url = '$ip/view_daycare';

      var response = await http.post(Uri.parse(url), body: {'lid': loginId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        var data = jsonData['data'];

        setState(() {
          daycareList = List<Map<String, String>>.from(
            data.map((item) => {
              'id': item['day_care_id'].toString(),
              'name': item['day_care_name'].toString(),
              'owner': item['owner_name'].toString(),
              'phone': item['phone'].toString(),
            }),
          );
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Daycare'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : daycareList.isEmpty
          ? const Center(
        child: Text("No daycares available", style: TextStyle(fontSize: 18)),
      )
          : ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: daycareList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                daycareList[index]['name']!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("Owner: ${daycareList[index]['owner']}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 5),
                  Text("Phone: ${daycareList[index]['phone']}",
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                          DaycareDetails(daycareId: daycareList[index]['id']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
