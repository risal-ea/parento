import 'package:flutter/material.dart';

class ViewMeetings extends StatelessWidget {
  const ViewMeetings({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("View meetings"),
        ),
        body: Padding(padding: EdgeInsets.all(16.0),
        child: Text("")),
      ),
    );
  }
}
