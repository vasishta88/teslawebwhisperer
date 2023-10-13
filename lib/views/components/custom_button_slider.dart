import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teslawebwhisperer/tesla_service.dart';

class CustomButtonSlider extends StatefulWidget {
  final Function(double) onAngleChanged;
  final Map<String, dynamic> vehicleData;

  const CustomButtonSlider({Key? key, required this.onAngleChanged, required this.vehicleData})
      : super(key: key);

  @override
  _CustomButtonSliderState createState() => _CustomButtonSliderState();
}

class _CustomButtonSliderState extends State<CustomButtonSlider> {
  double _currentAngle = 0;
  double _temperature = 16; // Make it nullable for now

  @override
  void initState() {
    super.initState();
    _initializeTemperature();
  }

  Future<void> _initializeTemperature() async {
    double? temp = await getDriverTemp(widget.vehicleData);
    setState(() {
      _temperature = temp ?? 0.0;  // Use the fetched temperature or default to 0.0
    });
  }


  @override
  Widget build(BuildContext context) {
    //double _temperature = getDriverTemp(widget.vehicleData) as double; // Placeholder starting temperature
    return GestureDetector(
      onPanUpdate: (details) {
        final center = Offset(340 / 2, 340 / 2);
        final delta = details.localPosition - center;
        final r = atan2(delta.dy, delta.dx);
        if (r > -pi / 2)  {
          setState(() {
            _currentAngle = r;
            widget.onAngleChanged(r);
            // Calculating temperature based on angle
            _temperature = 16 + ((_currentAngle + pi / 2) / pi) * 11;
            // Rounding to nearest 0.5 value
            _temperature = (2.0 * _temperature).round() / 2.0;
            if (_temperature > 27) _temperature = 27;
            if (_temperature < 16) _temperature = 16;
          });
        }
      },
      onTapDown: (details) {
        // Handling tap to adjust the slider position
        final center = Offset(340 / 2, 340 / 2);
        final delta = details.localPosition - center;
        final r = atan2(delta.dy, delta.dx);
        if (r > -pi / 2) {
          setState(() {
            _currentAngle = r;
            widget.onAngleChanged(r);
            // Calculating temperature based on angle
            _temperature = 16 + ((_currentAngle + pi / 2) / pi) * 11;
            // Rounding to nearest 0.5 value
            _temperature = (2.0 * _temperature).round() / 2.0;
            if (_temperature > 27) _temperature = 27;
            if (_temperature < 16) _temperature = 16;
          });
        }
      },
      child: Center(
        child: Container(
          height: 340,
          width: 340,
          decoration: const BoxDecoration(
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
          child: Stack(
            children: [
              // Inner circle
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: const BoxDecoration(
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
              CustomPaint(
                size: Size(340, 340),
                painter: _SliderPainter(_currentAngle),
              ),
              Center(
                child: Text(
                  "${_temperature}°C",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double angle;
  final Paint trackPaint;

  _SliderPainter(this.angle)
      : trackPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 70; // Adjusted to bring closer

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle + pi / 2,
      false,
      trackPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

