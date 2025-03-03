import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestForm extends StatefulWidget {
  final String daycareId;

  const RequestForm({Key? key, required this.daycareId}) : super(key: key);

  @override
  _RequestFormState createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final GlobalKey<FormState> _requestForm = GlobalKey<FormState>();
  final TextEditingController startDate = TextEditingController();
  final TextEditingController preferredSchedule = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Request Form",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF6C63FF),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _requestForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Start Date",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: startDate,
                decoration: const InputDecoration(
                  hintText: "Select start date",
                  prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter start date";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              const Text(
                "Preferred Schedule",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: preferredSchedule,
                decoration: const InputDecoration(
                  hintText: "What days/times work best for you?",
                  prefixIcon: Icon(Icons.schedule, color: Color(0xFF6C63FF)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter preferred schedule";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50.0,
          child: ElevatedButton(
            onPressed: () async {
              if (_requestForm.currentState!.validate()) {
                try {
                  final sh = await SharedPreferences.getInstance();
                  String loginId = sh.getString('login_id') ?? '';
                  String url = sh.getString('url') ?? '';

                  if (loginId.isEmpty || url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: Missing login or server info'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  var response = await http.post(
                    Uri.parse('$url/admition_request'),
                    body: {
                      'startDate': startDate.text.trim(),
                      'schedule': preferredSchedule.text.trim(),
                      'daycareId': widget.daycareId,
                      'lid': loginId,
                    },
                  );

                  var jsonData = json.decode(response.body);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(jsonData['status'] == 'success' ?
                      'Request sent successfully!' : 'Failed to send request.'),
                      backgroundColor: jsonData['status'] == 'success' ? Colors.green : Colors.red,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('An error occurred. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              "Submit Request",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}