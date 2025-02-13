import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Complaint extends StatelessWidget {
  Complaint({super.key});

  final GlobalKey<FormState> _sendComplaint = GlobalKey<FormState>();
  final TextEditingController complaint = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Complaint"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _sendComplaint,
            child: Column(
              children: [
                TextFormField(
                  controller: complaint,
                  decoration: InputDecoration(labelText: "Complaint"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter you compliant";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_sendComplaint.currentState!.validate()) {
                        try {
                          final sh = await SharedPreferences.getInstance();
                          String login_id = sh.getString('login_id') ?? '';

                          if (login_id.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Login is not found! please login.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          String url = sh.getString('url') ?? '';

                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Server URL is not configured.'),
                              ),
                            );
                            return;
                          }

                          var data = await http.post(
                            Uri.parse(url + "and_send_complaint"),
                            body: {
                              'complaint': complaint.text.trim(),
                              'lid': login_id,
                            },
                          );


                          var jsonData = json.decode(data.body);
                          String status = jsonData['status'].toString();

                          if (status == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Complaint send successfully!'),
                              duration: Duration(seconds: 3),
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to send complaint.'),
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
                      }else{
                        print("Form is invalid");
                      }
                    },
                    child: Text("Submit"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
