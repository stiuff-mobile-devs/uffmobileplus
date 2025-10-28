import 'package:flutter/material.dart';

class CustomPolygon extends StatelessWidget {
  final List<Offset> points;
  final Color? color;

  const CustomPolygon({super.key, required this.points, this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 56.0,
        width: double.infinity,
        child: CustomPaint(
          painter: PolygonPainter(points, color),
        ),
      ),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final List<Offset> points;
  final Color? color;

  PolygonPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color ?? Colors.black.withOpacity(0.70)
      ..style = PaintingStyle.fill;

    final Path path = Path()..moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
