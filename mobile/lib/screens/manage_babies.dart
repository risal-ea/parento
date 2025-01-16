import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageBabies extends StatelessWidget {
  final GlobalKey<FormState> _manageBabieKey = GlobalKey<FormState>();
  final TextEditingController baby_id = TextEditingController();
  final TextEditingController parent_id = TextEditingController();
  final TextEditingController baby_name = TextEditingController();
  final TextEditingController baby_dob = TextEditingController();
  final TextEditingController baby_gender = TextEditingController();
  final TextEditingController baby_photo = TextEditingController();
  final TextEditingController health_issues = TextEditingController();
  final TextEditingController medical_condition = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Manage Babies'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _manageBabieKey,
            child: Column(
              children: [
                TextFormField(
                  controller: baby_name,
                  decoration: InputDecoration(labelText: "Baby Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the name";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: baby_dob,
                  decoration: InputDecoration(labelText: "Date of Birth"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the DOB";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: baby_gender,
                  decoration: InputDecoration(labelText: "Gender"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the gender";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: health_issues,
                  decoration: InputDecoration(labelText: "Health Issues"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please specify any health issues";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: medical_condition,
                  decoration: InputDecoration(labelText: "Medical Condition"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the medical condition";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_manageBabieKey.currentState!.validate()) {
                      try {
                        final sh = await SharedPreferences.getInstance();
                        String login_id = sh.getString('login_id') ?? '';

                        if (login_id.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Login ID not found. Please log in first.'),
                            duration: Duration(seconds: 3),
                          ));
                          return;
                        }

                        String url = sh.getString("url") ?? '';

                        if (url.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Server URL is not configured.'),
                            duration: Duration(seconds: 3),
                          ));
                          return;
                        }

                        var data = await http.post(
                          Uri.parse(url + "and_manage_babie"),
                          body: {
                            "baby_name": baby_name.text.trim(),
                            "parent_id": parent_id.text.trim(),
                            "baby_dob": baby_dob.text.trim(),
                            "baby_gender": baby_gender.text.trim(),
                            "baby_photo": baby_photo.text.trim(),
                            "health_issues": health_issues.text.trim(),
                            "medical_condition": medical_condition.text.trim(),
                            "lid": login_id,
                          },
                        );

                        print(data.body);

                        var jsonData = json.decode(data.body);
                        String status = jsonData['status'].toString();

                        if (status == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Baby details saved successfully!'),
                            duration: Duration(seconds: 3),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to save baby details.'),
                            duration: Duration(seconds: 3),
                          ));
                        }
                      } catch (e) {
                        print("Error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('An error occurred. Please try again.'),
                          duration: Duration(seconds: 3),
                        ));
                      }
                    } else {
                      print("Form is invalid");
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
