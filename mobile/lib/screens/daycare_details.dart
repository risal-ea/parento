import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/view_facilities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'request_form.dart';
import 'package:mobile/screens/feedback.dart';

class DaycareDetails extends StatefulWidget {
  final String daycareId;

  const DaycareDetails({Key? key, required this.daycareId}) : super(key: key);

  @override
  _DaycareDetailsState createState() => _DaycareDetailsState();
}

class _DaycareDetailsState extends State<DaycareDetails> {
  Map<String, dynamic>? daycare;
  bool isLoading = true;
  bool hasError = false;

  // Define primary color as a constant
  final Color primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    fetchDaycareDetails();
  }

  Future<void> fetchDaycareDetails() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString('url') ?? '';
      String url = '$ip/daycare_details';

      var response = await http.post(
        Uri.parse(url),
        body: {'day_care_id': widget.daycareId},
      );

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        setState(() {
          daycare = jsonData['details'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          "Daycare Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      )
          : hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              "Failed to load daycare details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: fetchDaycareDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Try Again"),
            ),
          ],
        ),
      )
          : daycare == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 60,
              color: Colors.amber[700],
            ),
            SizedBox(height: 16),
            Text(
              "No daycare details available",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              daycare!['day_care_name'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    daycare!['adress'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  daycare!['operating_time'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Card
                  _buildInfoSection(
                    title: "Description",
                    icon: Icons.info_outline,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        daycare!['daycare_discription'],
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Contact & Details Section
                  _buildInfoSection(
                    title: "Details & Contact Information",
                    icon: Icons.contact_phone_outlined,
                    child: Column(
                      children: [
                        _buildDetailTile(
                          icon: Icons.person,
                          title: "Owner",
                          value: daycare!['owner_name'],
                        ),
                        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                        _buildDetailTile(
                          icon: Icons.phone,
                          title: "Phone",
                          value: daycare!['phone'],
                        ),
                        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                        _buildDetailTile(
                          icon: Icons.verified_outlined,
                          title: "License Number",
                          value: daycare!['license_number'],
                        ),
                        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                        _buildDetailTile(
                          icon: Icons.people_alt_outlined,
                          title: "Capacity",
                          value: daycare!['capacity'],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Action Buttons Section
                  Text(
                    "Available Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),

                  _buildActionButton(
                    icon: Icons.room_preferences_outlined,
                    label: "View Facilities",
                    onPressed: () {
                      print("Navigating to ViewFacilities with daycareId: ${widget.daycareId}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewFacilities(daycareId: widget.daycareId),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 12),

                  _buildActionButton(
                    icon: Icons.app_registration,
                    label: "Request Admission",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestForm(daycareId: widget.daycareId),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 12),

                  _buildActionButton(
                    icon: Icons.rate_review_outlined,
                    label: "Submit Feedback",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendFeedback(daycareId: widget.daycareId),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          child,
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryColor.withOpacity(0.7),
            size: 18,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}