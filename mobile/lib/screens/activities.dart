import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Activities extends StatefulWidget {
  final String babyId;

  const Activities({super.key, required this.babyId});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> with SingleTickerProviderStateMixin {
  List<Map<String, String>> activities = [];
  bool isLoading = true;
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
      duration: const Duration(milliseconds: 300),
    );
    load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    load();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });

    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString('login_id') ?? '';
      String ip = sh.getString("url") ?? "";
      String url = "$ip/Activities";

      var response = await http.post(Uri.parse(url), body: {
        'lid': login_id,
        'baby_id': widget.babyId,
      });

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        var arr = jsonData['data'] as List;

        setState(() {
          activities = arr.map<Map<String, String>>((activity) {
            return {
              'Date': activity['date'].toString(),
              'Type': activity['activity_type'].toString(),
              'Description': activity['description'].toString(),
              'Start Time': activity['start_time'].toString(),
              'End Time': activity['end_time'].toString(),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar("Failed to load activities", isError: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar("Error loading activities", isError: true);
      print("Error: $e");
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
        duration: Duration(seconds: 2),
      ),
    );
  }

  IconData getActivityIcon(String type) {
    switch (type) {
      case 'Sleeping':
        return Icons.bedtime;
      case 'Playing':
        return Icons.sports_baseball;
      case 'Studying':
        return Icons.menu_book;
      default:
        return Icons.event;
    }
  }

  Color getActivityColor(String type) {
    switch (type) {
      case 'Sleeping':
        return Colors.blue;
      case 'Playing':
        return Colors.orange;
      case 'Studying':
        return Colors.green;
      default:
        return primaryColor;
    }
  }

  Widget buildActivityCard(Map<String, String> activity) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animationController.value) * 20),
          child: Opacity(
            opacity: _animationController.value,
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showActivityDetails(activity);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: getActivityColor(activity['Type']!).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            getActivityIcon(activity['Type']!),
                            color: getActivityColor(activity['Type']!),
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['Type'] ?? "Activity",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                activity['Description'] ?? "",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${activity['Start Time'] ?? ""} - ${activity['End Time'] ?? ""}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getActivityColor(activity['Type']!).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activity['Date'] ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: getActivityColor(activity['Type']!),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActivityDetails(Map<String, String> activity) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: getActivityColor(activity['Type']!).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      getActivityIcon(activity['Type']!),
                      color: getActivityColor(activity['Type']!),
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    activity['Type'] ?? "Activity",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                activity['Description'] ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        activity['Date'] ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Time",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${activity['Start Time'] ?? ""} - ${activity['End Time'] ?? ""}",
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _animationController.forward();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Baby Activities",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: cardBgColor,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await load();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: isLoading
              ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          )
              : activities.isEmpty
              ? SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height - 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 60,
                    color: textSecondaryColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No activities found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Pull down to refresh",
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
              : ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return buildActivityCard(activities[index]);
            },
          ),
        ),
      ),
    );
  }
}