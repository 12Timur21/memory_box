import 'package:flutter/material.dart';

class RecorderButtonWithLine extends StatelessWidget {
  const RecorderButtonWithLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(241, 180, 136, 1),
                  offset: Offset(0, -10),
                ),
              ],
            ),
            width: 5,
            height: 30,
          ),
          Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(241, 180, 136, 1),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
