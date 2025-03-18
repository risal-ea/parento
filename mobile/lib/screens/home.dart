import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/components/bottom_nav_bar.dart';
import 'package:mobile/screens/activities.dart';
import 'package:mobile/screens/baby_details.dart';
import 'package:mobile/screens/notifications.dart';
import 'package:mobile/screens/scanner.dart';
import 'package:mobile/screens/view_daycare.dart';
import 'package:mobile/screens/complaint.dart';
import 'package:mobile/screens/view_meetings.dart';
import 'package:mobile/screens/parent_profile.dart';
import 'package:mobile/screens/chat.dart';
import 'package:mobile/actions/baby_selection.dart';
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
  List<Map<String, dynamic>> notifications = [];
  OverlayEntry? _notificationOverlay;

  // Colors for the futuristic theme
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color secondaryColor = const Color(0xFF2A2D3E);
  final Color accentColor = const Color(0xFF00D3B0);
  final Color bgColor = const Color(0xFFF7F9FC);
  final Color cardBgColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF2A2D3E);
  final Color textSecondaryColor = const Color(0xFF7C7C7C);

  final List<Map<String, dynamic>> quickActions = [
    {'title': 'View Daycare', 'icon': Icons.business, 'color': const Color(0xFF00D3B0)},
    {'title': 'Send Complaint', 'icon': Icons.feedback, 'destination': Complaint(), 'color': const Color(0xFFFF7D54)},
    {'title': 'View Meetings', 'icon': Icons.calendar_today, 'destination': ViewMeetings(), 'color': const Color(0xFF6C63FF)},
  ];

  // Updated navItems to use identifiers instead of widget instances
  final List<Map<String, dynamic>> navItems = [
    {'index': 0, 'screen': 'Home'},
    {'index': 1, 'screen': 'Notifications'},
    {'index': 2, 'screen': 'ParentProfile'},
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
    fetchNotificationsAndShow();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notificationOverlay?.remove();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && selectedBabyId.isNotEmpty) {
      fetchData();
      fetchNotificationsAndShow();
    }
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    final selectedNav = navItems.firstWhere((item) => item['index'] == index);

    Widget? destination;
    switch (selectedNav['screen']) {
      case 'Home':
        destination = const Home();
        break;
      case 'Notifications':
        destination = Notifications(babyId: selectedBabyId); // Pass selectedBabyId to Notifications
        break;
      case 'ParentProfile':
        destination = ParentProfile();
        break;
    }

    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination!),
      ).then((_) {
        setState(() {
          _selectedIndex = 0; // Reset to Home after returning
        });
        fetchData();
        fetchNotificationsAndShow();
      });
    }
  }

  void _showCenterNotification(String message) {
    _notificationOverlay?.remove();
    _notificationOverlay = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: _animationController,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_notificationOverlay!);
    _animationController.forward(from: 0.0);

    Future.delayed(const Duration(seconds: 4), () {
      _animationController.reverse().then((_) {
        _notificationOverlay?.remove();
        _notificationOverlay = null;
      });
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
        duration: const Duration(seconds: 2),
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
    fetchNotificationsAndShow();
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

      var response = await http.post(
        Uri.parse(url),
        body: {"login_id": login_id, "baby_id": selectedBabyId},
      );

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

          activities.sort((a, b) => DateTime.parse("${b['Date']} ${b['StartTime']}").compareTo(DateTime.parse("${a['Date']} ${a['StartTime']}")));
          isLoading = false;
          isRefreshing = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
        _showSnackBar("Failed to fetch data: ${jsonData['message']}", isError: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
      _showSnackBar("Error loading data: $e", isError: true);
    }
  }

  Future<void> fetchNotificationsAndShow() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString("login_id") ?? "";
      String ip = sh.getString("url") ?? "";
      String url = "$ip/notifications";

      if (login_id.isEmpty || ip.isEmpty) return;

      var response = await http.post(
        Uri.parse(url),
        body: {"lid": login_id},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(jsonData['data']);
          });

          DateTime now = DateTime.now();
          String currentDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

          String? shownNotificationsJson = sh.getString('shown_notifications_$currentDate');
          Set<String> shownNotifications = shownNotificationsJson != null
              ? Set<String>.from(json.decode(shownNotificationsJson))
              : {};

          for (var notification in notifications) {
            String notificationDate = notification['date_time']?.toString().substring(0, 10) ?? '';
            String notificationId = notification['notification_id']?.toString() ?? notification['notification'].hashCode.toString();

            if (notificationDate == currentDate && !shownNotifications.contains(notificationId)) {
              _showCenterNotification(notification['notification'] ?? "You have a new notification!");
              shownNotifications.add(notificationId);
              await sh.setString('shown_notifications_$currentDate', json.encode(shownNotifications.toList()));
              break;
            }
          }
        }
      }
    } catch (e) {
      _showSnackBar("Error fetching notifications: $e", isError: true);
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
          if (end.isBefore(start)) end = end.add(const Duration(days: 1));
          totalHours += end.difference(start).inMinutes / 60.0;
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
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryColor)),
          const SizedBox(height: 4),
          Text(duration, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  Widget buildQuickActionButton(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Widget destination = action['title'] == 'View Daycare'
            ? (selectedBabyId.isEmpty ? Container() : Daycare(selectedBabyId: selectedBabyId))
            : action['destination'] as Widget;

        if (action['title'] == 'View Daycare' && selectedBabyId.isEmpty) {
          _showSnackBar("Please select a baby first", isError: true);
          return;
        }

        Navigator.push(context, PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        )).then((_) => fetchData());
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: action['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(action['icon'], color: action['color'], size: 24),
            ),
            const SizedBox(height: 12),
            Text(action['title'], textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryColor)),
          ],
        ),
      ),
    );
  }

  Widget buildActivityItem(Map<String, dynamic> activity) {
    IconData getActivityIcon() => {'Sleeping': Icons.bedtime, 'Playing': Icons.sports_baseball, 'Studying': Icons.menu_book}[activity['Type']] ?? Icons.category;
    Color getActivityColor() => {'Sleeping': Colors.blue, 'Playing': Colors.orange, 'Studying': Colors.green}[activity['Type']] ?? primaryColor;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: getActivityColor().withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(getActivityIcon(), color: getActivityColor(), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity['Type'] ?? "Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryColor)),
              const SizedBox(height: 4),
              Text(activity['Description'] ?? "", style: TextStyle(fontSize: 14, color: textSecondaryColor)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(activity['Date'] ?? "", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryColor)),
            const SizedBox(height: 4),
            Text("${activity['StartTime'] ?? ""} - ${activity['EndTime'] ?? ""}", style: TextStyle(fontSize: 12, color: textSecondaryColor)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: activities.isEmpty
          ? Container(
        height: 150,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 48, color: textSecondaryColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text("No activities recorded yet", style: TextStyle(fontSize: 16, color: textSecondaryColor)),
          ],
        ),
      )
          : Column(
        children: activities.take(4).map((activity) => Column(
          children: [
            buildActivityItem(activity),
            if (activities.indexOf(activity) < activities.take(4).length - 1)
              Divider(height: 24, thickness: 1, color: Colors.grey.withOpacity(0.1)),
          ],
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text("Parento", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Scanner()));
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFF6C63FF),
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 15,),
              GestureDetector(
                onTap: () {
                  if (selectedBabyId.isNotEmpty) {
                    Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => BabyDetails(babyId: selectedBabyId),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    )).then((_) => fetchData());
                  }
                },
                child: BabySelection(onBabySelected: updateSelectedBaby),
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
            await fetchNotificationsAndShow();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Hello Parent!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              Text("Track your child's daily activities and development in real-time.",
                                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.child_care, color: Colors.white, size: 42),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Daily Activity Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimaryColor)),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(child: SizedBox(height: 170, child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))))
                      : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      buildActivityCard("Sleep", Icons.bedtime, Colors.blue, calculateDuration('Sleeping')),
                      buildActivityCard("Eat", Icons.restaurant, Colors.orange, calculateDuration('Eating')),
                      buildActivityCard("Study", Icons.menu_book, Colors.green, calculateDuration('Studying')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimaryColor)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: quickActions.map((action) => buildQuickActionButton(action)).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text("Latest Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimaryColor)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          if (selectedBabyId.isNotEmpty) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Activities(babyId: selectedBabyId))).then((_) => fetchData());
                          } else {
                            _showSnackBar("Please select a baby first", isError: true);
                          }
                        },
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Row(
                          children: [
                            Text("See all", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 12, color: primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  isLoading
                      ? const Center(child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))))
                      : buildActivitiesCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (selectedBabyId.isNotEmpty) {
              Navigator.push(context, PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => Chat(babyId: selectedBabyId),
                transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(scale: animation, child: child),
              )).then((_) => fetchData());
            } else {
              _showSnackBar("Please select a baby first", isError: true);
            }
          },
          backgroundColor: primaryColor,
          child: const Icon(Icons.chat, color: Colors.white),
          elevation: 4,
        ),
      ),
    );
  }
}