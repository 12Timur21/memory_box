import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';

class RecorderButtonWithIcon extends StatelessWidget {
  const RecorderButtonWithIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 46,
          width: 46,
          margin: const EdgeInsets.only(
            bottom: 5,
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
                AppIcons.voice,
                height: 28,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
          child: Text(
            'Запись',
            style: TextStyle(
              color: AppColors.tacao,
              fontFamily: 'TTNorms',
              fontWeight: FontWeight.normal,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
