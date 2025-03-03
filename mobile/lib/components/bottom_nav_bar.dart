import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {
  // Controller for the ripple effect
  late List<AnimationController> _rippleControllers;
  late List<Animation<double>> _rippleAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize controllers for each nav item (now only 3 items)
    _rippleControllers = List.generate(
      3,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    // Create ripple animations
    _rippleAnimations = _rippleControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutQuart,
        ),
      );
    }).toList();

    // Start animation for initial selected tab
    _playRippleAnimation(widget.currentIndex);
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _playRippleAnimation(widget.currentIndex);
    }
  }

  void _playRippleAnimation(int index) {
    for (var i = 0; i < _rippleControllers.length; i++) {
      if (i == index) {
        _rippleControllers[i].forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _rippleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        height: 65, // Adjusted for 3 items
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) { // Now only 3 items
              bool isSelected = widget.currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onTap(index);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple effect animation
                      if (isSelected)
                        AnimatedBuilder(
                          animation: _rippleAnimations[index],
                          builder: (context, child) {
                            return Container(
                              width: 50 * _rippleAnimations[index].value,
                              height: 50 * _rippleAnimations[index].value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2A2D3E).withOpacity(
                                  0.2 * (1 - _rippleAnimations[index].value),
                                ),
                              ),
                            );
                          },
                        ),

                      // Icon only, no label
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        transform: Matrix4.identity()
                          ..scale(isSelected ? 1.2 : 1.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isSelected)
                              Container(
                                width: 35,
                                height: 35,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6C63FF),
                                      Color(0xFF6C63FF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            Icon(
                              _getIcon(index),
                              size: 24,
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.notifications_rounded;
      case 2:
        return Icons.person_rounded; // Moved Profile icon up (was index 3)
      default:
        return Icons.home_rounded;
    }
  }
}
