import 'package:flutter/material.dart';
import 'package:mobile/screens/activities.dart';
import 'package:mobile/screens/check_in_n_out.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BabyDetails extends StatefulWidget {
  final String babyId;

  const BabyDetails({Key? key, required this.babyId}) : super(key: key);

  @override
  State<BabyDetails> createState() => _BabyDetailsState();
}

class _BabyDetailsState extends State<BabyDetails> {
  String name = "";
  String dob = "";
  String photo = "";
  String dietryRestriction = "";
  String medicalCondition = "";
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url") ?? "";
      String url = '$ip/baby_details';

      print("Fetching data for babyId: ${widget.babyId}");

      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"baby_id": widget.babyId},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success' && jsonData["data"].isNotEmpty) {
        var babyData = jsonData["data"][0];

        setState(() {
          name = babyData['baby_name'].toString();
          dob = babyData['baby_dob'].toString();
          photo = babyData['baby_photo'].toString();
          dietryRestriction = babyData['allergies_or_dietry_restriction'].toString();
          medicalCondition = babyData['medical_condition'].toString();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error in fetchData: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Baby Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
            : hasError
            ? Center(child: Text("Failed to load baby details. Try again later."))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: photo.isNotEmpty
                  ? Image.network(photo, height: 150, width: 150, fit: BoxFit.cover)
                  : Icon(Icons.person, size: 100), // Placeholder if no photo
            ),
            SizedBox(height: 10),
            Text("Name: $name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Date of Birth: $dob"),
            Text("Dietary Restrictions: ${dietryRestriction.isEmpty ? 'None' : dietryRestriction}"),
            Text("Medical Condition: ${medicalCondition.isEmpty ? 'None' : medicalCondition}"),
            SizedBox(height: 20),

            // Buttons for Activities and Check-in
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Activities(babyId: widget.babyId)),
                );
              },
              child: Text('Activities'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckInNOut(babyId: widget.babyId)),
                );
              },
              child: Text('Check in and out'),
            ),
          ],
        ),
      ),
    );
  }
}
