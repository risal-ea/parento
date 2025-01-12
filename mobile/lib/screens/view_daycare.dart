import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Daycare extends StatefulWidget {
  const Daycare({super.key});

  @override
  State<Daycare> createState() => _DaycareState();
}

class _DaycareState extends State<Daycare> {
  List<String> daycare_name = <String>[];
  List<String> owner_name = <String>[];
  List<String> phone = <String>[];
  List<String> adress = <String>[];
  List<String> license_number = <String>[];
  List<String> capacity = <String>[];
  List<String> operating_time = <String>[];
  List<String> daycare_discription = <String>[];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    List<String> daycare_name = <String>[];
    List<String> owner_name = <String>[];
    List<String> phone = <String>[];
    List<String> adress = <String>[];
    List<String> license_number = <String>[];
    List<String> capacity = <String>[];
    List<String> operating_time = <String>[];
    List<String> daycare_discription = <String>[];

    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString('login_id') ?? '';
      String ip = sh.getString('url') ?? '';
      String url = ip + 'view_daycare';

      var data = await http.post(
        Uri.parse(url),body:{'lid':login_id},
      );

      var jasonData = json.decode(data.body);
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
