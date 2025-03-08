import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/components/bottom_nav_bar.dart';
import 'package:mobile/screens/activities.dart';
import 'package:mobile/screens/baby_details.dart';
import 'package:mobile/screens/notifications.dart';
import 'package:mobile/screens/view_daycare.dart';
import 'package:mobile/screens/complaint.dart';
import 'package:mobile/screens/view_meetings.dart';
import 'package:mobile/screens/parent_profile.dart';
import 'package:mobile/screens/chat.dart';
import 'package:mobile/bottom_sheet/baby_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<Map<String, dynamic>> activities = [];
  int _selectedIndex = 0;
  String selectedBabyPhoto = "";
  String selectedBabyId = "";
  bool isLoading = true;
  bool isRefreshing = false;
  late AnimationController _animationController;

  // Colors for the futuristic theme
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color secondaryColor = const Color(0xFF2A2D3E);
  final Color accentColor = const Color(0xFF00D3B0);
  final Color bgColor = const Color(0xFFF7F9FC);
  final Color cardBgColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF2A2D3E);
  final Color textSecondaryColor = const Color(0xFF7C7C7C);

  final List<Map<String, dynamic>> quickActions = [
    {
      'title': 'View Daycare',
      'icon': Icons.business,
      'color': const Color(0xFF00D3B0),
    },
    {
      'title': 'Send Complaint',
      'icon': Icons.feedback,
      'destination': Complaint(),
      'color': const Color(0xFFFF7D54),
    },
    {
      'title': 'View Meetings',
      'icon': Icons.calendar_today,
      'destination': ViewMeetings(),
      'color': const Color(0xFF6C63FF),
    },
  ];

  final List<Map<String, dynamic>> navItems = [
    {
      'index': 0,
      'screen': null, // Home screen
    },
    {
      'index': 1,
      'screen': Notifications(),
    },
    {
      'index': 2,
      'screen': ParentProfile(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addObserver(this);
    fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (selectedBabyId.isNotEmpty) {
        fetchData();
      }
    }
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    final selectedNav = navItems.firstWhere((item) => item['index'] == index);

    if (selectedNav['screen'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => selectedNav['screen']),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
        fetchData();
      });
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

  void updateSelectedBaby(String newPhoto, String babyId) {
    HapticFeedback.selectionClick();
    setState(() {
      selectedBabyPhoto = newPhoto;
      selectedBabyId = babyId;
      activities.clear();
      isLoading = true;
    });
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isRefreshing = true;
      isLoading = true;
    });

    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString("login_id") ?? "";
      String ip = sh.getString("url") ?? "";
      String url = "$ip/home";

      print("Fetching data from: $url");
      print("Login ID: $login_id");
      print("Baby ID: $selectedBabyId");

      var response = await http.post(
        Uri.parse(url),
        body: {"login_id": login_id, "baby_id": selectedBabyId},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        var arr = jsonData['data'] as List;

        setState(() {
          activities = arr.map<Map<String, dynamic>>((activity) {
            return {
              'Date': activity['date'].toString(),
              'Type': activity['activity_type'].toString(),
              'Description': activity['description'].toString(),
              'StartTime': activity['start_time'].toString(),
              'EndTime': activity['end_time'].toString(),
            };
          }).toList();

          activities.sort((a, b) {
            DateTime dateA = DateTime.parse("${a['Date']} ${a['StartTime']}");
            DateTime dateB = DateTime.parse("${b['Date']} ${b['StartTime']}");
            return dateB.compareTo(dateA);
          });

          isLoading = false;
          isRefreshing = false;
          print("Activities loaded: ${activities.length}");
          print("Sorted activities: ${activities.map((a) => "${a['Date']} ${a['StartTime']} - ${a['Type']}").toList()}");
        });
      } else {
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
        _showSnackBar("Failed to fetch data: ${jsonData['message']}", isError: true);
        print("Fetch failed: ${jsonData['message']}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
      _showSnackBar("Error loading data: $e", isError: true);
      print("Error fetching data: $e");
    }
  }

  String calculateDuration(String activityType) {
    double totalHours = 0.0;
    for (var activity in activities) {
      if (activity['Type'] == activityType) {
        String startTime = activity['StartTime'] ?? "";
        String endTime = activity['EndTime'] ?? "";
        try {
          DateTime start = DateTime.parse("2024-01-01 $startTime");
          DateTime end = DateTime.parse("2024-01-01 $endTime");
          if (end.isBefore(start)) {
            end = end.add(Duration(days: 1));
          }
          Duration duration = end.difference(start);
          totalHours += duration.inMinutes / 60.0;
        } catch (e) {
          print("Error parsing $activityType time: $e");
        }
      }
    }
    return totalHours > 0 ? "${totalHours.toStringAsFixed(1)} hrs" : "0 hrs";
  }

  Widget buildActivityCard(String title, IconData icon, Color color, String duration) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            duration,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuickActionButton(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Widget destination;

        if (action['title'] == 'View Daycare') {
          if (selectedBabyId.isEmpty) {
            _showSnackBar("Please select a baby first", isError: true);
            return;
          }
          destination = Daycare(selectedBabyId: selectedBabyId);
        } else {
          destination = action['destination'] as Widget;
        }

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => destination,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ).then((_) => fetchData());
      },
      child: Container(
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
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action['icon'], color: action['color'], size: 24),
            ),
            SizedBox(height: 12),
            Text(
              action['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActivityItem(Map<String, dynamic> activity) {
    IconData getActivityIcon() {
      switch (activity['Type']) {
        case 'Sleeping':
          return Icons.bedtime;
        case 'Playing':
          return Icons.sports_baseball;
        case 'Studying':
          return Icons.menu_book;
        default:
          return Icons.category;
      }
    }

    Color getActivityColor() {
      switch (activity['Type']) {
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

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: getActivityColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            getActivityIcon(),
            color: getActivityColor(),
            size: 24,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimaryColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                activity['Description'] ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              activity['Date'] ?? "",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "${activity['StartTime'] ?? ""} - ${activity['EndTime'] ?? ""}",
              style: TextStyle(
                fontSize: 12,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildActivitiesCard() {
    return Container(
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
      padding: EdgeInsets.all(16),
      child: activities.isEmpty
          ? Container(
        height: 150,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 48,
              color: textSecondaryColor.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              "No activities recorded yet",
              style: TextStyle(
                fontSize: 16,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: activities.take(4).map((activity) {
          return Column(
            children: [
              buildActivityItem(activity),
              if (activities.indexOf(activity) < activities.take(4).length - 1)
                Divider(
                  height: 24,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text(
                "Parento",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (selectedBabyId.isNotEmpty) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            BabyDetails(babyId: selectedBabyId),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    ).then((_) => fetchData());
                  }
                },
                child: BabySelection(
                  onBabySelected: updateSelectedBaby,
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          color: primaryColor,
          backgroundColor: cardBgColor,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await fetchData();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Container(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello Parent!",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Track your child's daily activities and development in real-time.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.child_care,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Daily Activity Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  isLoading
                      ? Center(
                    child: SizedBox(
                      height: 170,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                    ),
                  )
                      : GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      buildActivityCard(
                        "Sleep",
                        Icons.bedtime,
                        Colors.blue,
                        calculateDuration('Sleeping'),
                      ),
                      buildActivityCard(
                        "Eat",
                        Icons.restaurant,
                        Colors.orange,
                        calculateDuration('Playing'),
                      ),
                      buildActivityCard(
                        "Study",
                        Icons.menu_book,
                        Colors.green,
                        calculateDuration('Studying'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: quickActions.map((action) => buildQuickActionButton(action)).toList(),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        "Latest Activities",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          if (selectedBabyId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Activities(babyId: selectedBabyId),
                              ),
                            ).then((_) => fetchData());
                          } else {
                            _showSnackBar("Please select a baby first", isError: true);
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "See all",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  isLoading
                      ? Center(
                    child: SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                    ),
                  )
                      : buildActivitiesCard(),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (selectedBabyId.isNotEmpty) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      Chat(babyId: selectedBabyId),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                ),
              ).then((_) => fetchData());
            } else {
              _showSnackBar("Please select a baby first", isError: true);
            }
          },
          backgroundColor: primaryColor,
          child: Icon(Icons.chat, color: Colors.white),
          elevation: 4,
        ),
      ),
    );
  }
}