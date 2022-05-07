import 'package:flutter/material.dart';

class TextLogo extends StatelessWidget {
  const TextLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            'MemoryBox',
            style: TextStyle(
              letterSpacing: 6,
              fontSize: 48,
              fontFamily: 'TTNorms',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          'Твой голос всегда рядом',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            color: Colors.white,
            fontFamily: 'TTNorms',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
