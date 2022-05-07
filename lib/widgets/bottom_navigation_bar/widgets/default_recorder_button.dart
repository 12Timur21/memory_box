import 'package:flutter/material.dart';

class DefaultRecorderButton extends StatelessWidget {
  const DefaultRecorderButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: 46,
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(241, 180, 136, 1),
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 3),
        ),
      ),
    );
  }
}
