import 'package:flutter/material.dart';

class AppBarMultirowTitle extends StatelessWidget {
  const AppBarMultirowTitle({
    this.subtitile,
    this.title,
    Key? key,
  }) : super(key: key);

  final String? title;
  final String? subtitile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: title,
          style: const TextStyle(
            fontFamily: 'TTNorms',
            fontWeight: FontWeight.w700,
            fontSize: 36,
            letterSpacing: 0.5,
          ),
          children: subtitile != null
              ? <TextSpan>[
                  TextSpan(
                    text: '\n $subtitile',
                    style: const TextStyle(
                      fontFamily: 'TTNorms',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
