import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DashedLinePainter extends CustomPainter {
  DashedLinePainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 2, dashSpace = 2, startX = 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DashDivider extends StatelessWidget {
  const DashDivider({
    Key? key,
    this.thickness = 0.5,
    this.color = Colors.grey,
  }) : super(key: key);
  final double? thickness;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: thickness,
      child: CustomPaint(painter: DashedLinePainter(color: color)),
    );
  }
}
