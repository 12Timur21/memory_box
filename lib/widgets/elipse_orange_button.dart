import 'package:flutter/material.dart';

class ElipseOrangeButton extends StatefulWidget {
  const ElipseOrangeButton({
    required this.onPress,
    required this.text,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPress;
  final String text;
  @override
  _ElipseOrangeButtonState createState() => _ElipseOrangeButtonState();
}

class _ElipseOrangeButtonState extends State<ElipseOrangeButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onPress,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          primary: const Color.fromRGBO(241, 180, 136, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Text(
          widget.text,
          style: const TextStyle(
            fontFamily: 'TTNorms',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            letterSpacing: 0.1,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
