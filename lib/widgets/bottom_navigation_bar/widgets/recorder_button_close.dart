import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/resources/app_icons.dart';

class RecorderButtonClose extends StatelessWidget {
  const RecorderButtonClose({Key? key}) : super(key: key);

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
          child: SvgPicture.asset(
            AppIcons.arrowDown,
            color: Colors.white,
            height: 28,
          ),
        ),
      ),
    );
  }
}
