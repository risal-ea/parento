import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/baby_details.dart'; // Import the BabyDetails screen

class BabySelection extends StatefulWidget {
  final Function(String) onBabySelected; // Callback when a baby is selected

  const BabySelection({super.key, required this.onBabySelected});

  @override
  State<BabySelection> createState() => _BabySelectionState();
}

class _BabySelectionState extends State<BabySelection> {
  List<Map<String, String>> babies = [];
  String selectedBabyPhoto = ""; // Default Image will be handled in UI

  @override
  void initState() {
    super.initState();
    fetchBabies();
  }

  Future<void> fetchBabies() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString("login_id") ?? "";
      String ip = sh.getString("url") ?? "";
      String url = '$ip/baby_profile';

      var response = await http.post(
        Uri.parse(url),
        body: {'lid': login_id},
      );

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        setState(() {
          babies = List<Map<String, String>>.from(jsonData['data'].map((item) => {
            'baby_id': item['baby_id']?.toString() ?? "",  // Handle null baby_id
            'baby_name': item['baby_name']?.toString() ?? "Unknown Baby",  // Handle null name
            'baby_photo': item['baby_photo']?.toString() ?? "",  // Handle null photo
          }));
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void showBabySelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Baby",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: babies.length,
                itemBuilder: (context, index) {
                  String babyPhoto = babies[index]['baby_photo']?.toString() ?? "";
                  String babyId = babies[index]['baby_id'] ?? "";

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300], // Light grey background
                      backgroundImage: babyPhoto.isNotEmpty ? NetworkImage(babyPhoto) : null,
                      child: babyPhoto.isEmpty
                          ? const Icon(Icons.child_care, size: 30, color: Colors.white)
                          : const Icon(Icons.child_care, size: 30, color: Colors.white), // Show default icon if no image
                    ),
                    title: Text(babies[index]['baby_name']!),
                    onTap: () {
                      print("Tapped on baby: ${babies[index]['baby_name']}, babyId: $babyId");
                      Navigator.pop(context);

                      if (babyId.isNotEmpty) {
                        print("Navigating to BabyDetails with babyId: $babyId");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BabyDetails(babyId: babyId),
                          ),
                        );
                      } else {
                        print("Error: baby_id is empty!");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Baby profile is incomplete!")),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CircleAvatar(
        radius: 22.5,
        backgroundColor: Colors.grey[300], // Light grey background
        backgroundImage: selectedBabyPhoto.isNotEmpty ? NetworkImage(selectedBabyPhoto) : null,
        child: selectedBabyPhoto.isEmpty
            ? const Icon(Icons.child_care, size: 30, color: Colors.white)
            : const Icon(Icons.child_care, size: 30, color: Colors.white), // Show default icon if no image
      ),
      onLongPress: () {
        showBabySelectionSheet(context);
      },
    );
  }
}
