import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendFeedback extends StatelessWidget {

  final String daycareId;
  SendFeedback({Key? key, required this.daycareId}) : super(key: key);


  final GlobalKey<FormState> _sendFeedback = GlobalKey<FormState>();
  final TextEditingController feedback = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Send Feedback"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _sendFeedback,
            child: Column(
              children: [
                TextFormField(
                  controller: feedback,
                  decoration: InputDecoration(labelText: "Feedback"),
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
                      if (_sendFeedback.currentState!.validate()) {
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
                            Uri.parse(url + "and_send_feedback"),
                            body: {
                              'feedback': feedback.text.trim(),
                              'daycareId': daycareId,
                              'lid': login_id,
                            },
                          );


                          var jsonData = json.decode(data.body);
                          String status = jsonData['status'].toString();

                          if (status == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('feedback send successfully!'),
                              duration: Duration(seconds: 3),
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to send feedback.'),
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
