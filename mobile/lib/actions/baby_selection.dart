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
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchBabies();
  }

  Future<void> fetchBabies() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final sh = await SharedPreferences.getInstance();
      String loginId = sh.getString("login_id") ?? "";
      String ip = sh.getString("url") ?? "";

      if (loginId.isEmpty || ip.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Login information or server URL is missing";
        });
        return;
      }

      String url = '$ip/baby_profile';

      var response = await http.post(
        Uri.parse(url),
        body: {'lid': loginId},
      );

      if (response.statusCode != 200) {
        setState(() {
          isLoading = false;
          errorMessage = "Server error: ${response.statusCode}";
        });
        return;
      }

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
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = jsonData['message'] ?? "Failed to load babies";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            // Add extra padding for bottom to account for keyboard
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sheet Handle
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Child",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Color(0xFF6C63FF)),
                    onPressed: fetchBabies,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const Text(
                "Select a child profile or add a new one",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 24),

              // Baby List
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6C63FF),
                  ),
                )
              else if (errorMessage.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchBabies,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Try Again"),
                      ),
                    ],
                  ),
                )
              else if (babies.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.child_care, color: Color(0xFF6C63FF), size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "No children profiles found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: babies.length,
                      itemBuilder: (context, index) {
                        final baby = babies[index];
                        final isSelected = selectedBabyId == baby['baby_id'];

                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFFF0EEFF) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Color(0xFF6C63FF) : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF6C63FF).withOpacity(isSelected ? 1.0 : 0.7),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: baby['baby_photo']!.isNotEmpty
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  baby['baby_photo']!,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.child_care, size: 24, color: Colors.white),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                                  : Icon(Icons.child_care, size: 24, color: Colors.white),
                            ),
                            title: Text(
                              baby['baby_name'] ?? "Unknown Baby",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF333333),
                              ),
                            ),
                            trailing: isSelected
                                ? Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF6C63FF),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                                : null,
                            onTap: () {
                              Navigator.pop(context);
                              updateSelectedBaby(baby['baby_photo']!, baby['baby_id']!);
                            },
                          ),
                        );
                      },
                    ),
                  ),

              const SizedBox(height: 16),

              // Add Baby Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text(
                    "ADD NEW CHILD",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddBabies()),
                    ).then((_) => fetchBabies()); // Refresh after adding
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
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
          ).then((_) => fetchBabies()); // Refresh after viewing details
        }
      },
      onLongPress: () {
        showBabySelectionSheet(context);
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF6C63FF).withOpacity(0.1),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF6C63FF).withOpacity(0.7),
              child: selectedBabyPhoto.isNotEmpty
                  ? ClipOval(
                child: Image.network(
                  selectedBabyPhoto,
                  fit: BoxFit.cover,
                  width: 44,
                  height: 44,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.child_care, size: 24, color: Colors.white),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      ),
                    );
                  },
                ),
              )
                  : Icon(Icons.child_care, size: 24, color: Colors.white),
            ),
          ),
          if (babies.length > 1)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}