import 'package:flutter/material.dart';

class CheckInNOut extends StatefulWidget {
  final String babyId;

  const CheckInNOut({super.key, required this.babyId});

  @override
  State<CheckInNOut> createState() => _CheckInNOutState();
}

class _CheckInNOutState extends State<CheckInNOut> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-In & Check-Out"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Baby ID: ${widget.babyId}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Check-in and Check-out functionality here."),
          ],
        ),
      ),
    );
  }
}
