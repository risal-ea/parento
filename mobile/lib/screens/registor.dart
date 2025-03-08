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
  final TextEditingController confirmPassword = TextEditingController();
  String selectedGender = 'Male';
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        parentDob.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _register() async {
    if (!_registerKey.currentState!.validate()) return;

    // Check if passwords match
    if (password.text != confirmPassword.text) {
      _showSnackBar('Passwords do not match');
      return;
    }

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
        _showSnackBar('Registration Successful!', isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => login()),
        );
      } else {
        _showSnackBar('Registration Failed! Try again.');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : Color(0xFF4CAF50),
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF6C63FF);
    final secondaryColor = Color(0xFFF5F5FF);

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => login()),
          ),
        ),
        title: Text(
          "Create Account",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Decorative header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.child_care, color: primaryColor, size: 32),
                    SizedBox(width: 10),
                    Text(
                      "KidsCare",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Parent Registration",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 30),

                // Registration Form
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(24),
                  child: Form(
                    key: _registerKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Parent Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),

                        _buildTextField(
                          controller: parentName,
                          label: "Full Name",
                          hint: "Enter parent's full name",
                          icon: Icons.person,
                          primaryColor: primaryColor,
                        ),

                        _buildTextField(
                            controller: parentEmail,
                            label: "Email Address",
                            hint: "Enter your email",
                            icon: Icons.email,
                            primaryColor: primaryColor,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return "Enter a valid email address";
                              }
                              return null;
                            }
                        ),

                        _buildTextField(
                          controller: parentPhone,
                          label: "Phone Number",
                          hint: "Enter your phone number",
                          icon: Icons.phone,
                          primaryColor: primaryColor,
                          keyboardType: TextInputType.phone,
                        ),

                        _buildTextField(
                          controller: parentAddress,
                          label: "Address",
                          hint: "Enter your address",
                          icon: Icons.home,
                          primaryColor: primaryColor,
                        ),

                        // Date of Birth picker
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: parentDob,
                              label: "Date of Birth",
                              hint: "YYYY-MM-DD",
                              icon: Icons.calendar_today,
                              primaryColor: primaryColor,
                            ),
                          ),
                        ),

                        // Gender dropdown
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedGender,
                            decoration: InputDecoration(
                              labelText: "Gender",
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              prefixIcon: Icon(Icons.wc, color: primaryColor),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            items: ['Male', 'Female', 'Other']
                                .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                                .toList(),
                            onChanged: (value) => setState(() => selectedGender = value!),
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Account Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),

                        _buildTextField(
                          controller: username,
                          label: "Username",
                          hint: "Create a username",
                          icon: Icons.person_outline,
                          primaryColor: primaryColor,
                        ),

                        _buildTextField(
                            controller: password,
                            label: "Password",
                            hint: "Create a strong password",
                            icon: Icons.lock_outline,
                            primaryColor: primaryColor,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            }
                        ),

                        _buildTextField(
                            controller: confirmPassword,
                            label: "Confirm Password",
                            hint: "Re-enter your password",
                            icon: Icons.lock_outline,
                            primaryColor: primaryColor,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password";
                              }
                              if (value != password.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            }
                        ),

                        SizedBox(height: 30),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              disabledBackgroundColor: primaryColor.withOpacity(0.6),
                            ),
                            child: isLoading
                                ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                                : Text("Create Account"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Login option
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => login()),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text("Sign In"),
                    ),
                  ],
                ),

                // Daycare-themed decorative footer
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, color: primaryColor.withOpacity(0.7)),
                    SizedBox(width: 10),
                    Icon(Icons.baby_changing_station, color: primaryColor.withOpacity(0.7)),
                    SizedBox(width: 10),
                    Icon(Icons.emoji_people, color: primaryColor.withOpacity(0.7)),
                    SizedBox(width: 10),
                    Icon(Icons.menu_book, color: primaryColor.withOpacity(0.7)),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          prefixIcon: Icon(icon, color: primaryColor),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator ?? (value) => value == null || value.isEmpty ? "$label is required" : null,
      ),
    );
  }
}