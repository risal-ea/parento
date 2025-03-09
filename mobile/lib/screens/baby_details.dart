import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/activities.dart';
import 'package:mobile/screens/check_in_n_out.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  String payment = "";
  String payment_status = "";
  String admission = "";
  bool isLoading = true;
  bool isProcessingPayment = false;
  bool hasError = false;
  String baseUrl = "";
  late Razorpay _razorpay;

  final Color primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    fetchData();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      isProcessingPayment = true;
    });

    try {
      String url = '${baseUrl}update_payment_status';
      var updateResponse = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "baby_id": widget.babyId,
          "payment_id": response.paymentId,
          "payment_status": "paid",
          "admission": admission, // Matches backend request.form['admission']
        },
      );

      print("Update payment response status: ${updateResponse.statusCode}");
      print("Update payment response body: ${updateResponse.body}");
      var jsonData = json.decode(updateResponse.body);

      if (updateResponse.statusCode == 200 && jsonData['status'] == 'success') {
        setState(() {
          payment_status = "paid";
          isProcessingPayment = false;
        });
        Fluttertoast.showToast(
            msg: "Payment Successful!",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        throw Exception("Failed to update payment status: ${jsonData['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      setState(() {
        isProcessingPayment = false;
      });
      Fluttertoast.showToast(
          msg: "Payment successful but status update failed. Please contact admin.",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.orange,
          textColor: Colors.white);
      print("Error updating payment status: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Payment Failed: ${response.message}",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "External Wallet Selected: ${response.walletName}",
        toastLength: Toast.LENGTH_LONG);
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
          name = babyData['baby_name']?.toString() ?? "";
          dob = babyData['baby_dob']?.toString() ?? "";
          photo = babyData['baby_photo']?.toString() ?? "";
          dietaryRestriction = babyData['allergies_or_dietry_restriction']?.toString() ?? "";
          medicalCondition = babyData['medical_condition']?.toString() ?? "";
          qrCodePath = babyData['qr_code']?.toString() ?? "";
          payment = babyData['payment']?.toString() ?? "";
          payment_status = babyData['payment_status']?.toString() ?? "";
          admission = babyData['admision']?.toString() ?? ""; // Matches your original /baby_details key
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

  String formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _initiatePayment() {
    if (payment.isEmpty) {
      Fluttertoast.showToast(
          msg: "Payment amount not available",
          backgroundColor: Colors.red);
      return;
    }

    double amount = 0;
    try {
      amount = double.parse(payment);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Invalid payment amount",
          backgroundColor: Colors.red);
      return;
    }

    int amountInPaise = (amount * 100).toInt();

    var options = {
      'key': 'rzp_test_edrzdb8Gbx5U5M',
      'amount': amountInPaise,
      'name': 'Daycare Payment',
      'description': 'Payment for $name',
      'prefill': {'contact': '', 'email': ''},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay: $e");
      Fluttertoast.showToast(
          msg: "Could not open payment gateway",
          backgroundColor: Colors.red);
    }
  }

  void _showFullScreenQR(String qrCodeUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('QR Code'),
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Scan to check in/out',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.network(
                      qrCodeUrl,
                      height: 280,
                      width: 280,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print("Error loading full screen QR code: $error");
                        return Column(
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              "Failed to load QR Code",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String photoUrl = photo.isNotEmpty && photo != "null" ? '$baseUrl$photo' : '';
    String qrCodeUrl = qrCodePath.isNotEmpty ? '$baseUrl$qrCodePath' : '';

    if (photoUrl.isNotEmpty) print("Baby Photo URL: $photoUrl");
    if (qrCodeUrl.isNotEmpty) print("QR Code URL: $qrCodeUrl");

    bool showPaymentSection = payment.isNotEmpty || payment_status.isNotEmpty || admission.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          "Baby Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              "Failed to load baby details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Try Again"),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 20, bottom: 30),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl.isNotEmpty
                          ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading baby photo: $error");
                          return Icon(
                            Icons.child_care,
                            size: 70,
                            color: primaryColor.withOpacity(0.7),
                          );
                        },
                      )
                          : Icon(
                        Icons.child_care,
                        size: 70,
                        color: primaryColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "DOB: ${formatDate(dob)}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            if (showPaymentSection)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 16),
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
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.payment,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Payment Details",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (payment.isNotEmpty) SizedBox(height: 4),
                                if (payment.isNotEmpty)
                                  Text(
                                    "Amount: ₹$payment",
                                    style: TextStyle(fontSize: 15, color: Colors.black54),
                                  ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      "Status: ",
                                      style: TextStyle(fontSize: 15, color: Colors.black54),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: payment_status.toLowerCase() == "paid"
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        payment_status.isEmpty
                                            ? "Not Set"
                                            : payment_status.capitalize(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: payment_status.toLowerCase() == "paid"
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (admission.isNotEmpty) SizedBox(height: 4),
                                if (admission.isNotEmpty)
                                  Text(
                                    "Admission: $admission",
                                    style: TextStyle(fontSize: 15, color: Colors.black54),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (payment_status.toLowerCase() == "pending" && payment.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 16),
                          child: ElevatedButton(
                            onPressed: isProcessingPayment ? null : _initiatePayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: isProcessingPayment
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text("Processing...")
                              ],
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment),
                                SizedBox(width: 8),
                                Text(
                                  "Pay Now",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    title: "Dietary Restrictions",
                    content: dietaryRestriction.isEmpty ? 'None' : dietaryRestriction,
                    icon: Icons.restaurant,
                  ),
                  SizedBox(height: 16),
                  _buildInfoCard(
                    title: "Medical Condition",
                    content: medicalCondition.isEmpty ? 'None' : medicalCondition,
                    icon: Icons.medical_services,
                  ),
                  SizedBox(height: 24),
                  if (qrCodeUrl.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 24),
                      padding: EdgeInsets.all(20),
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
                        children: [
                          Text(
                            "Quick Check-in/out",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _showFullScreenQR(qrCodeUrl),
                            child: Container(
                              width: 180,
                              height: 180,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    qrCodeUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      print("Error loading QR code: $error");
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline,
                                              color: Colors.red, size: 40),
                                          SizedBox(height: 8),
                                          Text(
                                            "Failed to load QR Code",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tap to enlarge",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.event_note,
                          label: "Activities",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Activities(babyId: widget.babyId)),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.login,
                          label: "Check In/Out",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CheckInNOut(babyId: widget.babyId)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}