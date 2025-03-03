import 'package:flutter/material.dart';
import 'package:mobile/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewFacilities extends StatefulWidget {
  final String daycareId;

  ViewFacilities({Key? key, required this.daycareId}) : super(key: key);

  @override
  State<ViewFacilities> createState() => _ViewFacilitiesState();
}

class _ViewFacilitiesState extends State<ViewFacilities> with SingleTickerProviderStateMixin {
  List<Map<String, String>> facilities = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    load(); // Fetch data whenever dependencies change
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });

    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString('login_id') ?? '';
      String ip = sh.getString('url') ?? '';
      String url = '$ip/view_facility';

      print("Sending request to: $url with daycareId: ${widget.daycareId}");

      var data = await http.post(Uri.parse(url), body: {
        'lid': login_id,
        'daycareId': widget.daycareId,
      });

      print("Response Status: ${data.statusCode}");
      print("Response Body: ${data.body}");

      var jsonData = json.decode(data.body);
      if (jsonData['status'] == 'success') {
        var arr = jsonData['data'];

        setState(() {
          facilities = arr.map<Map<String, String>>((facility) {
            return {
              'name': facility['facility_name'].toString(),
              'type': facility['facility_type'].toString(),
              'description': facility['facility_des'].toString(),
              'capacity': facility['facility_capacity'].toString(),
              'image': facility['facility_image'].toString(),
              'op_hrs': facility['operating_hrs'].toString(),
              'safety': facility['safety_measures'].toString(),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        print("Failed to load facilities.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF6C63FF),
        scaffoldBackgroundColor: Color(0xFFF8F9FF),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF8F8BFF),
          background: Color(0xFFF8F9FF),
        ),
        fontFamily: 'Poppins',
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Daycare Facilities',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF8F8BFF),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home())
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: load,
            ),
          ],
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home())
            );
            return true;
          },
          child: SafeArea(
            child: isLoading
                ? Center(
              child: LoadingIndicator(),
            )
                : facilities.isEmpty
                ? EmptyStateWidget(onRefresh: load)
                : Container(
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FF),
              ),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: facilities.length,
                itemBuilder: (BuildContext context, int index) {
                  return FacilityCard(
                    facility: facilities[index],
                    index: index,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FacilityCard extends StatelessWidget {
  final Map<String, String> facility;
  final int index;

  const FacilityCard({
    Key? key,
    required this.facility,
    required this.index,
  }) : super(key: key);

  IconData _getFacilityIcon(String facilityType) {
    switch(facilityType.toLowerCase()) {
      case 'playground':
        return Icons.park_outlined;
      case 'classroom':
        return Icons.school_outlined;
      case 'kitchen':
        return Icons.kitchen_outlined;
      case 'restroom':
        return Icons.wc_outlined;
      case 'nap room':
        return Icons.hotel_outlined;
      case 'medical room':
        return Icons.medical_services_outlined;
      default:
        return Icons.home_work_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            childrenPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6C63FF).withOpacity(0.8),
                    Color(0xFF8F8BFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getFacilityIcon(facility['type'] ?? ''),
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              facility['name'] ?? 'N/A',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              facility['type'] ?? 'N/A',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            trailing: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF6C63FF),
              ),
            ),
            children: [
              SizedBox(height: 8),
              Divider(
                color: Colors.grey.withOpacity(0.3),
                thickness: 1,
              ),
              SizedBox(height: 12),
              FacilityDetailItem(
                icon: Icons.description_outlined,
                title: "Description",
                value: facility['description'] ?? 'N/A',
              ),
              FacilityDetailItem(
                icon: Icons.people_outline,
                title: "Capacity",
                value: facility['capacity'] ?? 'N/A',
              ),
              FacilityDetailItem(
                icon: Icons.access_time,
                title: "Operating Hours",
                value: facility['op_hrs'] ?? 'N/A',
              ),
              FacilityDetailItem(
                icon: Icons.health_and_safety_outlined,
                title: "Safety Measures",
                value: facility['safety'] ?? 'N/A',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FacilityDetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const FacilityDetailItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Color(0xFF6C63FF),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black54,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6C63FF).withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Loading facilities...",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C63FF),
          ),
        ),
      ],
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyStateWidget({Key? key, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Color(0xFFEEEDFF),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.home_work_outlined,
              size: 50,
              color: Color(0xFF6C63FF),
            ),
          ),
          SizedBox(height: 24),
          Text(
            "No Facilities Found",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "There are no facilities available for this daycare center at the moment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 18),
                SizedBox(width: 8),
                Text(
                  "Refresh",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}