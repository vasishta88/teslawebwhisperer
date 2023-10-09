import 'dart:math';

import 'package:flutter/material.dart';

class CustomButtonSlider extends StatefulWidget {
  final Function(double) onAngleChanged;

  const CustomButtonSlider({
    required this.onAngleChanged,
    Key? key,
  }) : super(key: key);

  @override
  _CustomButtonSliderState createState() => _CustomButtonSliderState();
}

class _CustomButtonSliderState extends State<CustomButtonSlider> {
  double _angle = 0.0;  // Initialize with a default value

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        Offset centerOfSlider = Offset(340 / 2, 340 / 2);
        final touchPositionFromCenter = details.localPosition - centerOfSlider;
        _angle = touchPositionFromCenter.direction;

        widget.onAngleChanged(_angle);
        setState(() {});
      },
      child: CustomPaint(
        painter: _SliderPainter(_angle),
        child: Center(
          child: Container(
            height: 340,
            width: 340,
            decoration: BoxDecoration(
              color: Color(0xFF292D31),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset: Offset(-26, -26),
                  blurRadius: 60,
                  color: Color(0xff3a4145),
                ),
                BoxShadow(
                  offset: Offset(10, 10),
                  blurRadius: 20,
                  color: Color(0xFF13151A),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff2B2F33),
                  Color(0xff101113),
                ],
              ),
            ),
            child: Center(
              child: ClipOval(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Color(0xFF292D31),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(20, 20),
                        blurRadius: 40,
                        color: Color(0xFF13151A),
                      ),
                      BoxShadow(
                        offset: Offset(-2, -2),
                        blurRadius: 10,
                        color: Color(0xff282c2f),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff1d1f22),
                        Color(0xff323840),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double angle;

  _SliderPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;
    final Paint bluePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    final double angleInRadian = 5 * pi / 4 - angle;  // Adjusts starting position of the slider
    final double sweepAngle = 3 * pi / 2 * angleInRadian / (2 * pi);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 5 * pi / 4, sweepAngle, false, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
