import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _registerKey = GlobalKey<FormState>();
  final TextEditingController parentName = TextEditingController();
  final TextEditingController parentEmail = TextEditingController();
  final TextEditingController parentPhone = TextEditingController();
  final TextEditingController parentAddress = TextEditingController();
  final TextEditingController parentDob = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  String selectedGender = 'Male';
  bool isLoading = false;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        parentDob.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _register() async {
    if (!_registerKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final sh = await SharedPreferences.getInstance();
      String url = sh.getString("url") ?? "";

      var response = await http.post(
        Uri.parse(url + "and_registor"),
        body: {
          "name": parentName.text.trim(),
          "phone_number": parentPhone.text.trim(),
          "email": parentEmail.text.trim(),
          "address": parentAddress.text.trim(),
          "dob": parentDob.text.trim(),
          "gender": selectedGender,
          "username": username.text.trim(),
          "password": password.text.trim(),
        },
      );

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful!')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed! Try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _registerKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Create an Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    _buildTextField(parentName, "Parent Name", Icons.person),
                    _buildTextField(parentPhone, "Phone Number", Icons.phone),
                    _buildTextField(parentEmail, "Email", Icons.email),
                    _buildTextField(parentAddress, "Address", Icons.home),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _buildTextField(parentDob, "Date of Birth", Icons.calendar_today),
                      ),
                    ),
                    DropdownButtonFormField(
                      value: selectedGender,
                      decoration: InputDecoration(
                        labelText: "Gender",
                        prefixIcon: Icon(Icons.wc),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (value) => setState(() => selectedGender = value!),
                    ),
                    SizedBox(height: 10),
                    _buildTextField(username, "Username", Icons.person_outline),
                    _buildTextField(password, "Password", Icons.lock, obscureText: true),
                    SizedBox(height: 20),
                    isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: Text("Register", style: TextStyle(fontSize: 18)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => login()),
                      ),
                      child: Text("Already have an account? Login"),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value == null || value.isEmpty ? "Please enter $label" : null,
      ),
    );
  }
}
