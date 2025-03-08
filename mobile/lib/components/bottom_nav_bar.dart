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
  late List<AnimationController> _rippleControllers;
  late List<Animation<double>> _rippleAnimations;

  @override
  void initState() {
    super.initState();
    _rippleControllers = List.generate(
      3,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _rippleAnimations = _rippleControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart),
      );
    }).toList();
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
      } else {
        _rippleControllers[i].reverse();
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
      padding: const EdgeInsets.only(bottom: 20.0), // Fixed to bottom: 20.0 below
      child: Container(
        height: 65,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
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
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
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
                                  colors: [Color(0xFF6C63FF), Color(0xFF6C63FF)],
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
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.notifications_rounded;
      case 2:
        return Icons.person_rounded;
      default:
        return Icons.home_rounded;
    }
  }
}