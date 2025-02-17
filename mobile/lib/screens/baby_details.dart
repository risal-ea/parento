import 'package:flutter/material.dart';
import 'package:mobile/screens/Activities.dart';
import 'package:mobile/screens/check_in_n_out.dart';

class BabyDetails extends StatefulWidget {
  const BabyDetails({super.key});

  @override
  State<BabyDetails> createState() => _BabyDetailsState();
}

class _BabyDetailsState extends State<BabyDetails> {
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Activities()));
                },
                child: Text('Activities'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CheckInNOut()));
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
