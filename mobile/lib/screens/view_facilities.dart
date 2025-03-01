import 'package:flutter/material.dart';
import 'package:mobile/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewFacilities extends StatefulWidget {
  final String daycareId;

  ViewFacilities({Key? key, required this.daycareId}) : super(key: key);

  @override
  State<ViewFacilities> createState() => _ViewFacilitiesState();
}

class _ViewFacilitiesState extends State<ViewFacilities> {
  List<Map<String, String>> facilities = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    load(); // Fetch data whenever dependencies change
  }

  Future<void> load() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString('login_id') ?? '';
      String ip = sh.getString('url') ?? '';
      String url = '$ip/view_facility';

      print("Sending request to: $url with daycareId: ${widget.daycareId}");

      var data = await http.post(Uri.parse(url), body: {
        'lid': login_id,
        'daycareId': widget.daycareId,
      });

      print("Response Status: ${data.statusCode}");
      print("Response Body: ${data.body}");

      var jsonData = json.decode(data.body);
      if (jsonData['status'] == 'success') {
        var arr = jsonData['data'];

        setState(() {
          facilities = arr.map<Map<String, String>>((facility) {
            return {
              'name': facility['facility_name'].toString(),
              'type': facility['facility_type'].toString(),
              'description': facility['facility_des'].toString(),
              'capacity': facility['facility_capacity'].toString(),
              'image': facility['facility_image'].toString(),
              'op_hrs': facility['operating_hrs'].toString(),
              'safety': facility['safety_measures'].toString(),
            };
          }).toList();
        });
      } else {
        print("Failed to load facilities.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('View Facility')),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
            return true;
          },
          child: SafeArea(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: facilities.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        FacilityDetailRow(
                            title: "Facility Name",
                            value: facilities[index]['name']!),
                        FacilityDetailRow(
                            title: "Type", value: facilities[index]['type']!),
                        FacilityDetailRow(
                            title: "Description",
                            value: facilities[index]['description']!),
                        FacilityDetailRow(
                            title: "Capacity",
                            value: facilities[index]['capacity']!),
                        FacilityDetailRow(
                            title: "OP hrs",
                            value: facilities[index]['op_hrs']!),
                        FacilityDetailRow(
                            title: "safety",
                            value: facilities[index]['safety']!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// **Reusable Widget for Facility Details**
class FacilityDetailRow extends StatelessWidget {
  final String title;
  final String value;

  const FacilityDetailRow(
      {super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
