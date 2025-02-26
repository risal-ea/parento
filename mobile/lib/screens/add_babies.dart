import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddBabies extends StatefulWidget {
  @override
  _AddBabiesState createState() => _AddBabiesState();
}

class _AddBabiesState extends State<AddBabies> {
  final GlobalKey<FormState> _manageBabieKey = GlobalKey<FormState>();
  final TextEditingController baby_name = TextEditingController();
  final TextEditingController baby_dob = TextEditingController();
  final TextEditingController baby_gender = TextEditingController();
  final TextEditingController health_issues = TextEditingController();
  final TextEditingController medical_condition = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveBabyDetails() async {
    if (!_manageBabieKey.currentState!.validate()) return;

    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString('login_id') ?? '';
      String url = sh.getString("url") ?? '';

      if (login_id.isEmpty || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login ID or Server URL not found.'),
          duration: Duration(seconds: 3),
        ));
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse(url + "and_manage_babie"));

      request.fields["baby_name"] = baby_name.text.trim();
      request.fields["baby_dob"] = baby_dob.text.trim();
      request.fields["baby_gender"] = baby_gender.text.trim();
      request.fields["health_issues"] = health_issues.text.trim();
      request.fields["medical_condition"] = medical_condition.text.trim();
      request.fields["lid"] = login_id;

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('baby_photo', _image!.path),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (jsonData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Baby details saved successfully!'),
          duration: Duration(seconds: 3),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save baby details.'),
          duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again.'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Manage Babies')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _manageBabieKey,
            child: Column(
              children: [
                TextFormField(
                  controller: baby_name,
                  decoration: InputDecoration(labelText: "Baby Name"),
                  validator: (value) => value!.isEmpty ? "Enter name" : null,
                ),
                TextFormField(
                  controller: baby_dob,
                  decoration: InputDecoration(labelText: "Date of Birth"),
                  validator: (value) => value!.isEmpty ? "Enter DOB" : null,
                ),
                TextFormField(
                  controller: baby_gender,
                  decoration: InputDecoration(labelText: "Gender"),
                  validator: (value) => value!.isEmpty ? "Enter gender" : null,
                ),
                TextFormField(
                  controller: health_issues,
                  decoration: InputDecoration(labelText: "Health Issues"),
                  validator: (value) => value!.isEmpty ? "Specify health issues" : null,
                ),
                TextFormField(
                  controller: medical_condition,
                  decoration: InputDecoration(labelText: "Medical Condition"),
                  validator: (value) => value!.isEmpty ? "Enter medical condition" : null,
                ),
                const SizedBox(height: 16.0),
                _image != null
                    ? Image.file(_image!, height: 100)
                    : Text('No image selected'),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Pick Image"),
                ),
                ElevatedButton(
                  onPressed: _saveBabyDetails,
                  child: Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
