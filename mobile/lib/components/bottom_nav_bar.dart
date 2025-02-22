import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75, // Increased height
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), // Rounded top-left corner
          topRight: Radius.circular(20), // Rounded top-right corner
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        elevation: 0, // Remove default shadow
        type: BottomNavigationBarType.fixed, // Ensures labels are always visible
        backgroundColor: Colors.transparent, // Transparent for the container styling to show
        selectedItemColor: Colors.blue, // Active icon color
        unselectedItemColor: Colors.grey, // Inactive icon color
        selectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        iconSize: 30, // Bigger icons
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications, size: 30), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: 'Profile'),
        ],
      ),
    );
  }
}
