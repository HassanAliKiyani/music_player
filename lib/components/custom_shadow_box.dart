import 'package:flutter/material.dart';
import 'dart:async';

class CustomShadowBox extends StatefulWidget {
  final Widget child;
  final Widget swipeWidget;
  const CustomShadowBox(
      {Key? key, required this.child, required this.swipeWidget})
      : super(key: key);

  @override
  _CustomShadowBoxState createState() => _CustomShadowBoxState();
}

class _CustomShadowBoxState extends State<CustomShadowBox>
    with SingleTickerProviderStateMixin {
  final List<Color> colors = [
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.yellow,
    Colors.red,
    Colors.pink,
    Colors.teal,
    Colors.yellowAccent
  ];

  late AnimationController _controller;
  late Animation<double> _animation;
  int currentColorIndex = 0;
  int nextColorIndex = 1;
  bool swipeLeft = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          currentColorIndex = nextColorIndex;
          nextColorIndex = (nextColorIndex + 1) % colors.length;
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 0) {
          setState(() {
            swipeLeft = false;
          });
        }

        // Swiping in left direction.
        if (details.delta.dx < 0) {
          setState(() {
            swipeLeft = true;
          });
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(-4, -4),
                  color: Color.lerp(colors[currentColorIndex],
                      colors[nextColorIndex], _animation.value)!,
                  blurRadius: 15,
                ),
                BoxShadow(
                  offset: const Offset(4, 4),
                  color: Color.lerp(colors[currentColorIndex],
                      colors[nextColorIndex], _animation.value)!,
                  blurRadius: 15,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: child,
          );
        },
        child: swipeLeft?widget.swipeWidget: widget.child,
      ),
    );
  }
}
