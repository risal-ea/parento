import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendFeedback extends StatefulWidget {
  final String daycareId;
  const SendFeedback({Key? key, required this.daycareId}) : super(key: key);

  @override
  State<SendFeedback> createState() => _SendFeedbackState();
}

class _SendFeedbackState extends State<SendFeedback> {
  final GlobalKey<FormState> _sendFeedback = GlobalKey<FormState>();
  final TextEditingController feedback = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitFeedback() async {
    if (!_sendFeedback.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sh = await SharedPreferences.getInstance();
      String loginId = sh.getString('login_id') ?? '';

      if (loginId.isEmpty) {
        _showSnackBar('Login is not found! Please login again.');
        return;
      }

      String url = sh.getString('url') ?? '';

      if (url.isEmpty) {
        _showSnackBar('Server URL is not configured.');
        return;
      }

      var response = await http.post(
        Uri.parse(url + "and_send_feedback"),
        body: {
          'feedback': feedback.text.trim(),
          'daycareId': widget.daycareId,
          'lid': loginId,
        },
      );

      var jsonData = json.decode(response.body);
      String status = jsonData['status'].toString();

      if (status == 'success') {
        _showSnackBar('Feedback sent successfully!');
        feedback.clear(); // Clear the text field after successful submission
      } else {
        _showSnackBar('Failed to send feedback.');
      }
    } catch (e) {
      print("Error: $e");
      _showSnackBar('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('success')
            ? Colors.green.shade700
            : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Send Feedback",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6C63FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _sendFeedback,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon and title
                const Icon(
                  Icons.feedback_outlined,
                  size: 64,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(height: 16),
                const Text(
                  "We Value Your Feedback",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your feedback helps us improve our service",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Feedback text field
                TextFormField(
                  controller: feedback,
                  decoration: InputDecoration(
                    labelText: "Your Feedback",
                    hintText: "Please share your thoughts...",
                    prefixIcon: const Icon(Icons.message, color: Color(0xFF6C63FF)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your feedback";
                    }
                    return null;
                  },
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                        : const Text(
                      "SUBMIT FEEDBACK",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}