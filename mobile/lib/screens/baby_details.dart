import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/activities.dart';
import 'package:mobile/screens/check_in_n_out.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BabyDetails extends StatefulWidget {
  final String babyId;

  const BabyDetails({Key? key, required this.babyId}) : super(key: key);

  @override
  State<BabyDetails> createState() => _BabyDetailsState();
}

class _BabyDetailsState extends State<BabyDetails> {
  String name = "";
  String dob = "";
  String photo = "";
  String dietaryRestriction = "";
  String medicalCondition = "";
  String qrCodePath = "";
  bool isLoading = true;
  bool hasError = false;
  String baseUrl = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String ip = sh.getString("url") ?? "";
      if (ip.isEmpty) {
        throw Exception("Base URL not found in SharedPreferences");
      }
      setState(() {
        baseUrl = ip.endsWith('/') ? ip : '$ip/';
      });
      String url = '${baseUrl}baby_details';

      print("Fetching data from: $url");
      print("Baby ID: ${widget.babyId}");

      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"baby_id": widget.babyId},
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['status'] == 'success' && jsonData["data"].isNotEmpty) {
        var babyData = jsonData["data"][0];

        setState(() {
          name = babyData['baby_name'] ?? "";
          dob = babyData['baby_dob'] ?? "";
          photo = babyData['baby_photo'] ?? "";
          dietaryRestriction = babyData['allergies_or_dietry_restriction'] ?? "";
          medicalCondition = babyData['medical_condition'] ?? "";
          qrCodePath = babyData['qr_code'] ?? "";
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error in fetchData: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void _showFullScreenQR(String qrCodeUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('QR Code'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Image.network(
              qrCodeUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading full screen QR code: $error");
                return Text("Failed to load QR Code");
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String photoUrl = photo.isNotEmpty ? '$baseUrl$photo' : '';
    String qrCodeUrl = qrCodePath.isNotEmpty ? '$baseUrl$qrCodePath' : '';

    if (photoUrl.isNotEmpty) print("Baby Photo URL: $photoUrl");
    if (qrCodeUrl.isNotEmpty) print("QR Code URL: $qrCodeUrl");

    return Scaffold(
      appBar: AppBar(title: Text("Baby Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : hasError
            ? Center(child: Text("Failed to load baby details. Try again later."))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: photoUrl.isNotEmpty
                    ? Image.network(
                  photoUrl,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading baby photo: $error");
                    return Icon(Icons.person, size: 100);
                  },
                )
                    : Icon(Icons.person, size: 100),
              ),
              SizedBox(height: 10),
              Text("Name: $name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Date of Birth: $dob"),
              Text("Dietary Restrictions: ${dietaryRestriction.isEmpty ? 'None' : dietaryRestriction}"),
              Text("Medical Condition: ${medicalCondition.isEmpty ? 'None' : medicalCondition}"),
              SizedBox(height: 20),
              Center(
                child: qrCodeUrl.isNotEmpty
                    ? GestureDetector(
                  onTap: () => _showFullScreenQR(qrCodeUrl),
                  child: Image.network(
                    qrCodeUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading QR code: $error");
                      return Text("Failed to load QR Code");
                    },
                  ),
                )
                    : Text("No QR Code Available"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Activities(babyId: widget.babyId)),
                  );
                },
                child: Text('Activities'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckInNOut(babyId: widget.babyId)),
                  );
                },
                child: Text('Check in and out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



