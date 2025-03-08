import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/actions/activity_detail.dart';
import 'package:mobile/actions/activity_analytics.dart';
import 'package:mobile/actions/activity_model.dart';
import 'package:mobile/actions/activity_timeline.dart';

class Activities extends StatefulWidget {
  final String babyId;

  const Activities({super.key, required this.babyId});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> with SingleTickerProviderStateMixin {
  List<ActivityModel> activities = [];
  bool isLoading = true;
  late TabController _tabController;

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
    _tabController = TabController(length: 3, vsync: this);
    load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    load();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      print("Response: $jsonData");

      if (jsonData['status'] == 'success') {
        var arr = jsonData['data'] as List;

        setState(() {
          activities = arr.map<ActivityModel>((activity) {
            return ActivityModel(
              date: activity['date'].toString(),
              type: activity['activity_type'].toString(),
              description: activity['description'].toString(),
              startTime: activity['start_time'].toString(),
              endTime: activity['end_time'].toString(),
            );
          }).toList();

          // Sort activities by date and start time (newest first)
          activities.sort((a, b) => b.dateTime.compareTo(a.dateTime));
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
      _showSnackBar("Error loading activities: $e", isError: true);
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
        margin: const EdgeInsets.all(16),
        elevation: 4,
        duration: const Duration(seconds: 2),
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
        title: Text(
          "Baby Activities",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondaryColor,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: "Activities"),
            Tab(icon: Icon(Icons.timeline), text: "Timeline"),
            Tab(icon: Icon(Icons.analytics), text: "Analytics"),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: cardBgColor,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await load();
        },
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        )
            : activities.isEmpty
            ? _buildEmptyState()
            : TabBarView(
          controller: _tabController,
          children: [
            // Activities List View
            _buildActivitiesList(),

            // Timeline View
            ActivityTimeline(activities: activities),

            // Analytics View
            ActivityAnalytics(activities: activities),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
            const SizedBox(height: 16),
            Text(
              "No activities found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
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
    );
  }

  Widget _buildActivitiesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailView(activity: activity),
                    )
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: activity.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        activity.icon,
                        color: activity.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.type,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${activity.startTime} - ${activity.endTime}",
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: activity.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            activity.date,
                            style: TextStyle(
                              fontSize: 12,
                              color: activity.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activity.durationText,
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}