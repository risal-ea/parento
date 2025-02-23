import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestForm extends StatelessWidget {
  final String daycareId;

  RequestForm({Key? key, required this.daycareId}) : super(key: key);


  final GlobalKey<FormState> _requestForm = GlobalKey<FormState>();
  final TextEditingController startDate = TextEditingController();
  final TextEditingController preferredSchedule = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Request form"),),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _requestForm,
            child: Column(
              children: [
                TextFormField(
                  controller: startDate,
                  decoration: InputDecoration(labelText: "Start date"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter start date";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: preferredSchedule,
                  decoration: InputDecoration(labelText: "Preferred schedule"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "what is the preferred schedule";
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
                      if (_requestForm.currentState!.validate()) {
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
                            Uri.parse(url + "admition_request"),
                            body: {
                              'startDate': startDate.text.trim(),
                              'schedule': preferredSchedule.text.trim(),
                              'daycareId': daycareId,
                              'lid': login_id,
                            },
                          );


                          var jsonData = json.decode(data.body);
                          String status = jsonData['status'].toString();

                          if (status == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('request send successfully!'),
                              duration: Duration(seconds: 3),
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to send request.'),
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
