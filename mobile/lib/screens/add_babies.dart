import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/screens/home.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AddBabies extends StatefulWidget {
  const AddBabies({Key? key}) : super(key: key);

  @override
  _AddBabiesState createState() => _AddBabiesState();
}

class _AddBabiesState extends State<AddBabies> {
  final GlobalKey<FormState> _manageBabyKey = GlobalKey<FormState>();
  final TextEditingController babyName = TextEditingController();
  final TextEditingController babyDob = TextEditingController();
  String selectedGender = 'Male';
  final TextEditingController healthIssues = TextEditingController();
  final TextEditingController medicalCondition = TextEditingController();
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  bool isLoading = false;

  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF6C63FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        babyDob.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveBabyDetails() async {
    if (!_manageBabyKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final sh = await SharedPreferences.getInstance();
      String loginId = sh.getString('login_id') ?? '';
      String url = sh.getString("url") ?? '';

      if (loginId.isEmpty || url.isEmpty) {
        _showSnackBar('Login ID or Server URL not found.');
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse(url + "and_manage_babie"));

      request.fields["baby_name"] = babyName.text.trim();
      request.fields["baby_dob"] = babyDob.text.trim();
      request.fields["baby_gender"] = selectedGender;
      request.fields["health_issues"] = healthIssues.text.trim();
      request.fields["medical_condition"] = medicalCondition.text.trim();
      request.fields["lid"] = loginId;

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('baby_photo', _image!.path),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (jsonData['status'] == 'success') {
        _showSnackBar('Baby details saved successfully!');
        _resetForm();
        // Redirect to existing Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        _showSnackBar('Failed to save baby details.');
      }
    } catch (e) {
      print("Error: $e");
      _showSnackBar('An error occurred. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF6C63FF),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  void _resetForm() {
    babyName.clear();
    babyDob.clear();
    setState(() {
      selectedGender = 'Male';
      _image = null;
    });
    healthIssues.clear();
    medicalCondition.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      primaryColor: const Color(0xFF6C63FF),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF6C63FF),
        secondary: const Color(0xFF6C63FF),
      ),
    );

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Baby Profile',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _manageBabyKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF6C63FF).withOpacity(0.5),
                                width: 3,
                              ),
                            ),
                            child: _image != null
                                ? ClipOval(
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                                : Icon(
                              Icons.child_care,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C63FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: babyName,
                      decoration: InputDecoration(
                        labelText: "Baby's Name",
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF6C63FF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Please enter baby's name" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: babyDob,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: InputDecoration(
                        labelText: "Date of Birth",
                        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
                        suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Please select date of birth" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: InputDecoration(
                        labelText: "Gender",
                        prefixIcon: const Icon(Icons.wc, color: Color(0xFF6C63FF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                      ),
                      items: genderOptions.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGender = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: healthIssues,
                      decoration: InputDecoration(
                        labelText: "Health Issues (if any)",
                        prefixIcon: const Icon(Icons.healing, color: Color(0xFF6C63FF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                      ),
                      maxLines: 2,
                      validator: (value) => value!.isEmpty ? "Write 'None' if no health issues" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: medicalCondition,
                      decoration: InputDecoration(
                        labelText: "Medical Condition (if any)",
                        prefixIcon: const Icon(Icons.medical_services, color: Color(0xFF6C63FF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                      ),
                      maxLines: 2,
                      validator: (value) => value!.isEmpty ? "Write 'None' if no medical conditions" : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveBabyDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "SAVE PROFILE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}