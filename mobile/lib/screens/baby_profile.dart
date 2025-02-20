import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/screens/baby_details.dart';
import 'package:mobile/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BabyProfile extends StatefulWidget {
  const BabyProfile({super.key});

  @override
  State<BabyProfile> createState() => _BabyProfileState();
}

class _BabyProfileState extends State<BabyProfile> {
  List<String> baby_name = [];
  List<String> bid = [];
  List<String> dob = [];
  List<String> photo = [];
  List<String> alergies = [];
  List<String> medical_condition = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString("login_id") ?? "";
      String ip = sh.getString("url") ?? "";
      String url = '$ip/baby_profile';

      var response = await http.post(
        Uri.parse(url),
        body: {'lid': login_id},
      );

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        var arr = jsonData['data'];

        setState(() {
          bid = arr.map<String>((item) => item['baby_id'].toString()).toList();
          baby_name = arr.map<String>((item) => item['baby_name'].toString()).toList();
          dob = arr.map<String>((item) => item['baby_dob'].toString()).toList();
          photo = arr.map<String>((item) => item['baby_photo'].toString()).toList();
          alergies = arr.map<String>((item) => item['allergies_or_dietry_restriction'].toString()).toList();
          medical_condition = arr.map<String>((item) => item['medical_condition'].toString()).toList();
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baby Profile')),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
          return false;
        },
        child: SafeArea(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: bid.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BabyDetails(babyId: bid[index]),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (photo[index].isNotEmpty)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                photo[index],
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 80),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text("Baby Name: ${baby_name[index]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("DOB: ${dob[index]}", style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text("Allergies: ${alergies[index]}", style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text("Medical Condition: ${medical_condition[index]}", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
