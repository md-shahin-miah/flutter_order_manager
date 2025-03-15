import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56, // Fixed height for consistency
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap:  onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor,fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}

