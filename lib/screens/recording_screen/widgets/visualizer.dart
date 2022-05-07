import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';

class Visualizer extends StatefulWidget {
  Visualizer({
    required this.recorderSubscription,
    Key? key,
  }) : super(key: key);
  Stream<RecordingDisposition>? recorderSubscription;

  @override
  _VisualizerState createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> {
  List<double> dbLevels = [0];
  bool _isRemoveModeEnable = false;
  bool _streamIsOpen = false;

  void enableRemoveMode() {
    _isRemoveModeEnable = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_streamIsOpen == false) {
      widget.recorderSubscription?.listen((event) {
        setState(() {
          _streamIsOpen = true;
          dbLevels.add(event.decibels ?? 0);
          if (_isRemoveModeEnable) {
            dbLevels.removeAt(0);
          }
        });
      });
    }

    return CustomPaint(
      size: const Size(400, double.infinity),
      painter: Painter(dbLevels, enableRemoveMode, _isRemoveModeEnable),
    );
  }
}

class Painter extends CustomPainter {
  Painter(this._dbLevels, this.enableRemoveMode, this._isRemoveModeEnable);
  final List<double> _dbLevels;
  Function enableRemoveMode;
  final bool _isRemoveModeEnable;

  final double _spaceBetwenLines = 2.2;
  double _halfHeight = 0;
  late double preventX;

  final paintSettings = Paint()
    ..color = Colors.black
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;

  void drawColumn(Canvas canvas, double dbLevel) {
    drawIndentLine(canvas);
    canvas.drawLine(
      Offset(preventX, _halfHeight - dbLevel / 1.2),
      Offset(preventX, _halfHeight + dbLevel / 1.2),
      paintSettings,
    );
    preventX = preventX + 2;
  }

  void drawIndentLine(Canvas canvas) {
    canvas.drawLine(
      Offset(preventX, _halfHeight),
      Offset(preventX + _spaceBetwenLines, _halfHeight),
      paintSettings,
    );
    preventX = preventX + _spaceBetwenLines;
  }

  void drawDeficientIndentLine(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, _halfHeight),
      Offset(size.width, _halfHeight),
      paintSettings,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    preventX = 0;
    _halfHeight = size.height / 2;
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (_isRemoveModeEnable) {
      drawDeficientIndentLine(canvas, size);
    }

    for (double level in _dbLevels) {
      if (level - 25 >= 0) {
        drawColumn(canvas, level);
      } else {
        drawIndentLine(canvas);
      }
      if (preventX >= size.width && _isRemoveModeEnable == false) {
        enableRemoveMode();
      }
    }
  }

  @override
  bool shouldRepaint(_) {
    return true;
  }
}
