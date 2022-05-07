import 'package:flutter/material.dart';

class HintPlate extends StatelessWidget {
  const HintPlate({required this.label, Key? key}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 21,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(246, 246, 246, 1),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.11),
            // spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 14,
            fontFamily: 'TTNorms',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1),
      ),
    );
  }
}
