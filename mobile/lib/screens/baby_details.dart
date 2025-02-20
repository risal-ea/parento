import 'package:flutter/material.dart';
import 'package:mobile/screens/activities.dart';
import 'package:mobile/screens/check_in_n_out.dart';

class BabyDetails extends StatefulWidget {
  final String babyId; // Accept baby ID

  const BabyDetails({Key? key, required this.babyId}) : super(key: key);

  @override
  State<BabyDetails> createState() => _BabyDetailsState();
}

class _BabyDetailsState extends State<BabyDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Baby details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Baby ID: ${widget.babyId}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    );
  }
}
