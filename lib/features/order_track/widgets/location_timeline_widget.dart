import 'package:flutter/material.dart';
import 'package:flutter_grocery/main.dart';

class LocationTimeline extends StatelessWidget {
  const LocationTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column( mainAxisSize: MainAxisSize.min, spacing: 3,
      children: [
        Icon(Icons.warehouse, color: Theme.of(context).primaryColor, size: 22), // Location Pin
        SizedBox(
          height: 30, // Adjust line height
          child: CustomPaint(
            painter: DottedLinePainter(),
          ),
        ),
        const Icon(Icons.location_on_rounded, color: Colors.green, size: 22), // Clock Icon
      ],
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Theme.of(Get.context!).primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashHeight = 4, dashSpace = 4, startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}