import 'package:flutter/material.dart';

class ActivityModel {
  final String date;
  final String type;
  final String description;
  final String startTime;
  final String endTime;

  ActivityModel({
    required this.date,
    required this.type,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  // Get datetime object for sorting
  DateTime get dateTime {
    try {
      return DateTime.parse("$date $startTime");
    } catch (e) {
      return DateTime.now();
    }
  }

  // Calculate duration between start and end time
  Duration get duration {
    try {
      final start = DateTime.parse("$date $startTime");
      final end = DateTime.parse("$date $endTime");
      return end.difference(start);
    } catch (e) {
      return const Duration(minutes: 0);
    }
  }

  // Format duration as string
  String get durationText {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  // Get icon based on activity type
  IconData get icon {
    switch (type.toLowerCase()) {
      case 'sleeping':
        return Icons.bedtime;
      case 'playing':
        return Icons.sports_baseball;
      case 'studying':
        return Icons.menu_book;
      case 'feeding':
        return Icons.restaurant;
      case 'bathing':
        return Icons.water_drop;
      case 'walking':
        return Icons.directions_walk;
      default:
        return Icons.event;
    }
  }

  // Get color based on activity type
  Color get color {
    switch (type.toLowerCase()) {
      case 'sleeping':
        return Colors.indigo;
      case 'playing':
        return Colors.orange;
      case 'studying':
        return Colors.green;
      case 'feeding':
        return Colors.red;
      case 'bathing':
        return Colors.lightBlue;
      case 'walking':
        return Colors.purple;
      default:
        return const Color(0xFF6C63FF);
    }
  }
}