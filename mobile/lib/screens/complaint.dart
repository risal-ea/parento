import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Complaint extends StatefulWidget {
  const Complaint({super.key});

  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _sendComplaint = GlobalKey<FormState>();
  final TextEditingController complaint = TextEditingController();
  bool isSubmitting = false;
  late AnimationController _animationController;

  // Colors for the modern theme
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color secondaryColor = const Color(0xFF2A2D3E);
  final Color bgColor = const Color(0xFFF7F9FC);
  final Color cardBgColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF2A2D3E);
  final Color textSecondaryColor = const Color(0xFF7C7C7C);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    complaint.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (_sendComplaint.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
      });

      try {
        final sh = await SharedPreferences.getInstance();
        String login_id = sh.getString('login_id') ?? '';

        if (login_id.isEmpty) {
          _showSnackBar('Login not found! Please login.', isError: true);
          setState(() {
            isSubmitting = false;
          });
          return;
        }

        String url = sh.getString('url') ?? '';

        if (url.isEmpty) {
          _showSnackBar('Server URL is not configured.', isError: true);
          setState(() {
            isSubmitting = false;
          });
          return;
        }

        var data = await http.post(
          Uri.parse("$url/and_send_complaint"),
          body: {
            'complaint': complaint.text.trim(),
            'lid': login_id,
          },
        );

        var jsonData = json.decode(data.body);
        String status = jsonData['status'].toString();

        if (status == 'success') {
          _showSnackBar('Complaint sent successfully!');
          complaint.clear();
        } else {
          _showSnackBar('Failed to send complaint.', isError: true);
        }
      } catch (e) {
        print("Error: $e");
        _showSnackBar('An error occurred. Please try again.', isError: true);
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    } else {
      print("Form is invalid");
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
        elevation: 4,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Send a Complaint",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animationController.value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - _animationController.value) * 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.feedback,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Have an Issue?",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Let us know your concerns and we'll address them promptly.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // Form Card with TextField
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _sendComplaint,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Complaint",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: complaint,
                                    maxLines: 8,
                                    minLines: 5,
                                    decoration: InputDecoration(
                                      hintText: "Describe your complaint here...",
                                      hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.6)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: textSecondaryColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: textSecondaryColor.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: primaryColor, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your complaint";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 100), // Space for bottom button
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Submit Button
          // Bottom Submit Button inside the Stack
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                    HapticFeedback.mediumImpact();
                    _submitComplaint();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    "Submit Complaint",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}