import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/screens/add_babies.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/baby_details.dart';

class BabySelection extends StatefulWidget {
  final Function(String, String) onBabySelected;

  const BabySelection({super.key, required this.onBabySelected});

  @override
  State<BabySelection> createState() => _BabySelectionState();
}

class _BabySelectionState extends State<BabySelection> {
  List<Map<String, String>> babies = [];
  String selectedBabyId = "";
  String selectedBabyPhoto = "";

  @override
  void initState() {
    super.initState();
    fetchBabies();
  }

  Future<void> fetchBabies() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String loginId = sh.getString("login_id") ?? "";
      String ip = sh.getString("url") ?? "";
      String url = '$ip/baby_profile';

      var response = await http.post(
        Uri.parse(url),
        body: {'lid': loginId},
      );

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        setState(() {
          babies = List<Map<String, String>>.from(jsonData['data'].map((item) => {
            'baby_id': item['baby_id']?.toString() ?? "",
            'baby_name': item['baby_name']?.toString() ?? "Unknown Baby",
            'baby_photo': item['baby_photo']?.toString() ?? "",
          }));

          // Automatically select the first baby if available
          if (babies.isNotEmpty) {
            updateSelectedBaby(babies.first['baby_photo'] ?? "", babies.first['baby_id'] ?? "");
          }
        });
      }
    } catch (e) {
      print("Error fetching babies: $e");
    }
  }

  void updateSelectedBaby(String babyPhoto, String babyId) {
    setState(() {
      selectedBabyId = babyId;
      selectedBabyPhoto = babyPhoto;
    });
    widget.onBabySelected(babyPhoto, babyId);
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
              ListView(
                shrinkWrap: true,
                children: [
                  // Existing baby profiles
                  ...babies.map((baby) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: selectedBabyId == baby['baby_id']
                          ? Colors.blue
                          : Colors.grey[300],
                      backgroundImage: baby['baby_photo']!.isNotEmpty
                          ? NetworkImage(baby['baby_photo']!)
                          : null,
                      child: baby['baby_photo']!.isEmpty
                          ? const Icon(Icons.child_care, size: 30, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      baby['baby_name'] ?? "Unknown Baby",
                      style: TextStyle(
                        fontWeight: selectedBabyId == baby['baby_id']
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedBabyId == baby['baby_id']
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    trailing: selectedBabyId == baby['baby_id']
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      updateSelectedBaby(baby['baby_photo']!, baby['baby_id']!);
                    },
                  )),

                  // Add Baby Option (Looks like a profile)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.add, size: 30, color: Colors.white),
                    ),
                    title: const Text(
                      "Add Baby",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddBabies()),
                      );
                    },
                  ),
                ],
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
      onTap: () {
        if (selectedBabyId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BabyDetails(babyId: selectedBabyId)),
          );
        }
      },
      onLongPress: () {
        showBabySelectionSheet(context);
      },
      child: CircleAvatar(
        radius: 22.5,
        backgroundColor: Colors.grey[300],
        backgroundImage: selectedBabyPhoto.isNotEmpty ? NetworkImage(selectedBabyPhoto) : null,
        child: selectedBabyPhoto.isEmpty
            ? const Icon(Icons.child_care, size: 30, color: Colors.white)
            : null,
      ),
    );
  }
}
