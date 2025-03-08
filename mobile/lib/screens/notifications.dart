import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Map<String, String>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    load();
    super.initState();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });

    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString('login_id') ?? '';
      String ip = sh.getString('url') ?? '';
      String url = '$ip/notifications';

      var data = await http.post(Uri.parse(url), body: {
        'lid': login_id,
      });

      print("Response Status: ${data.statusCode}");
      print("Response Body: ${data.body}");

      var jsonData = json.decode(data.body);
      if (jsonData['status'] == 'success') {
        var arr = jsonData['data'];

        setState(() {
          notifications = arr.map<Map<String, String>>((notification) {
            return {
              'notification': notification['notification'].toString(),
              'date_time': notification['date_time'].toString(),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        print("Failed to load Notifications.");
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
    return const Placeholder();
  }
}
