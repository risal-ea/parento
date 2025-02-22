import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DaycareDetails extends StatefulWidget {
  final String daycareId;

  const DaycareDetails({Key? key, required this.daycareId}) : super(key: key);

  @override
  _DaycareDetailsState createState() => _DaycareDetailsState();
}

class _DaycareDetailsState extends State<DaycareDetails> {
  Map<String, dynamic>? daycare;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDaycareDetails();
  }

  Future<void> fetchDaycareDetails() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString('url') ?? '';
      String url = '$ip/daycare_details';

      var response = await http.post(
        Uri.parse(url),
        body: {'day_care_id': widget.daycareId},
      );

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        setState(() {
          daycare = jsonData['details'];
          isLoading = false;
        });
      } else {
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

  Future<void> requestAdmission() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String userId = sh.getString('user_id') ?? '';
      String ip = sh.getString('url') ?? '';
      String url = '$ip/request_admission';

      var response = await http.post(
        Uri.parse(url),
        body: {'user_id': userId, 'day_care_id': widget.daycareId},
      );

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admission request sent successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send request")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daycare Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : daycare == null
          ? const Center(child: Text("Failed to load details"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("Daycare Name", daycare!['day_care_name']),
                      _buildDetailRow("Owner Name", daycare!['owner_name']),
                      _buildDetailRow("Phone Number", daycare!['phone']),
                      _buildDetailRow("Address", daycare!['adress']),
                      _buildDetailRow("License Number", daycare!['license_number']),
                      _buildDetailRow("Capacity", daycare!['capacity']),
                      _buildDetailRow("Operating Time", daycare!['operating_time']),
                      const SizedBox(height: 10),
                      const Text(
                        "Description",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(daycare!['daycare_discription'], style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: requestAdmission,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Request Admission",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
