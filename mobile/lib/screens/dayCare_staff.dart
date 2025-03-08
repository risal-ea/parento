import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DaycareStaff extends StatefulWidget {
  final String daycareId;

  const DaycareStaff({super.key, required this.daycareId});

  @override
  State<DaycareStaff> createState() => _DaycareStaffState();
}

class _DaycareStaffState extends State<DaycareStaff> {
  List<Map<String, String>> staffs = [];
  bool isLoading = true;
  final Color primaryColor = const Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    load(); // Call load when the widget initializes
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });

    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString('login_id') ?? '';
      String ip = sh.getString('url') ?? '';
      String url = '$ip/daycare_staff';

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
          staffs = arr.map<Map<String, String>>((staff) {
            return {
              'name': staff['staff_name'].toString(),
              'gender': staff['gender'].toString(),
              'position': staff['position'].toString(),
              'qualification': staff['qualification'].toString(),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        print("Failed to load staff details.");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daycare Staff',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: load,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        )
            : staffs.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 70,
                color: primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No staff members found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Refresh'),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: staffs.length,
          itemBuilder: (context, index) {
            final staff = staffs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: primaryColor.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 36,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    staff['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    staff['position'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        buildInfoRow(Icons.person_outline, 'Gender', staff['gender'] ?? 'N/A'),
                        const SizedBox(height: 12),
                        buildInfoRow(Icons.school, 'Qualification', staff['qualification'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryColor.withOpacity(0.7),
          size: 22,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}