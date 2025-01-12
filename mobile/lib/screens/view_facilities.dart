import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Facilities extends StatelessWidget {
  const Facilities({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Facilities'),
        ),
        body: const Center(
          child: Text('Yo yooh'),
        ),
      ),
    );
  }
}
