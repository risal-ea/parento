import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  // Constructor for ReusableCard class
  const ReusableCard({
    super.key,
    required this.colour, // Color of the card background
    required this.cardChild, // Widget to be displayed inside the card
    required this.onPress, // Callback function when the card is tapped
  });

  final Color colour; // Color for the card's background
  final Widget cardChild; // Widget displayed inside the card
  final void Function() onPress; // Function called when the card is tapped

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress, // Triggers onPress callback when the card is tapped
      child: Container(
        // margin: const EdgeInsets.all(5), // Margin around the card
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Rounded corners for the card
          color: colour, // Background color of the card
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              spreadRadius: 0.5, // How much the shadow spreads
              blurRadius: 4, // Blur radius for a softer effect
              offset: Offset(2, 4),
            )// Horizontal and vertical offset
          ]
        ),
        child: cardChild, // Widget inside the card
      ),
    );
  }
}