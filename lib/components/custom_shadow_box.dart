import 'package:flutter/material.dart';

class CustomShadowBox extends StatelessWidget {
  Widget child;
  CustomShadowBox({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              offset: Offset(-4, -4),
              color: Theme.of(context).colorScheme.tertiary,
              blurRadius: 15),
          BoxShadow(
              offset: Offset(4, 4),
              color: Colors.grey.shade500,
              blurRadius: 15)
        ],
      ),
      padding: EdgeInsets.all(12),
      child: child,
    );
  }
}
