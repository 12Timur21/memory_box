import 'package:flutter/material.dart';

class BackgroundPattern extends StatelessWidget {
  BackgroundPattern({
    required this.child,
    this.patternColor = const Color.fromRGBO(140, 132, 226, 1),
    this.height = 275,
    this.isShort = false,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Color patternColor;
  double height;
  final bool isShort;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (isShort) {
      height = 260;
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 246, 246, 1),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomPaint(
            size: Size(size.width, height),
            painter: Pattern(
              patternColor: patternColor,
            ),
          ),
          child
        ],
      ),
    );
  }
}

class Pattern extends CustomPainter {
  final Color patternColor;

  Pattern({required this.patternColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = patternColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(size.width, 0);
    path0.quadraticBezierTo(size.width, size.height * 0.7155000, size.width,
        size.height * 0.9540000);
    path0.quadraticBezierTo(size.width * 0.4942000, size.height * 1.0922000, 0,
        size.height * 0.8026000);
    path0.lineTo(0, 0);
    path0.close();

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
