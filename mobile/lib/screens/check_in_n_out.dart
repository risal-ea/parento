import 'package:flutter/material.dart';

class CheckInNOut extends StatefulWidget {
  const CheckInNOut({super.key});

  @override
  State<CheckInNOut> createState() => _CheckInNOutState();
}

class _CheckInNOutState extends State<CheckInNOut> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Baby details"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("check in and out")
            ],
          ),
        ),
      ),
    );
  }
}

