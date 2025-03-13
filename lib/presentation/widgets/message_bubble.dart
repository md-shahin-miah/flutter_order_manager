import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double triangleHeight;
  final double triangleWidth;
  final double triangleOffset;

  const MessageBubble({
    Key? key,
    required this.message,
    this.backgroundColor = const Color(0xFFF8E8DD),
    this.textColor = const Color(0xFF4A4A4A),
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16.0),
    this.triangleHeight = 16.0,
    this.triangleWidth = 30.0,
    this.triangleOffset = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Triangle pointer
        Transform.translate(
          offset: Offset(triangleOffset, 0),
          child: CustomPaint(
            size: Size(triangleWidth, triangleHeight),
            painter: TrianglePainter(backgroundColor),
          ),
        ),

        // Message container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

