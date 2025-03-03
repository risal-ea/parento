import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'daycare_details.dart';

class Daycare extends StatefulWidget {
  const Daycare({Key? key}) : super(key: key);

  @override
  State<Daycare> createState() => _DaycareState();
}

class _DaycareState extends State<Daycare> {
  List<Map<String, String>> daycareList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDaycares();
  }

  Future<void> loadDaycares() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String loginId = sh.getString('login_id') ?? '';
      String ip = sh.getString('url') ?? '';
      String url = '$ip/view_daycare';

      var response = await http.post(Uri.parse(url), body: {'lid': loginId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        var data = jsonData['data'];

        setState(() {
          daycareList = List<Map<String, String>>.from(
            data.map((item) => {
              'id': item['day_care_id'].toString(),
              'name': item['day_care_name'].toString(),
              'owner': item['owner_name'].toString(),
              'phone': item['phone'].toString(),
            }),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF), // Light background
      appBar: AppBar(
        title: const Text('View Daycares'),
        backgroundColor: const Color(0xFF6C63FF), // Home Page Theme Color
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : daycareList.isEmpty
          ? const Center(
        child: Text(
          "No daycares available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: daycareList.length,
          itemBuilder: (context, index) {
            return _buildDaycareCard(index);
          },
        ),
      ),
    );
  }

  Widget _buildDaycareCard(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DaycareDetails(daycareId: daycareList[index]['id']!),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Icon Avatar
            CircleAvatar(
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.15),
              radius: 28,
              child: const Icon(Icons.storefront_rounded, color: Color(0xFF6C63FF), size: 28),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    daycareList[index]['name']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Owner: ${daycareList[index]['owner']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Phone: ${daycareList[index]['phone']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            // Forward Icon
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF6C63FF), size: 20),
          ],
        ),
      ),
    );
  }
}
