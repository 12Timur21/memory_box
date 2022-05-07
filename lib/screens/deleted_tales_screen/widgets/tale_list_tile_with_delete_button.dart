import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/utils/incline.dart';

class TaleListTileWithDeleteButton extends StatelessWidget {
  const TaleListTileWithDeleteButton({
    required this.taleModel,
    required this.isPlay,
    required this.tooglePlayMode,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  final TaleModel taleModel;
  final bool isPlay;

  final VoidCallback tooglePlayMode;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(41),
        color: const Color.fromRGBO(246, 246, 246, 1),
        border: Border.all(
          color: const Color.fromRGBO(58, 58, 85, 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        leading: GestureDetector(
          onTap: tooglePlayMode,
          child: SvgPicture.asset(
            isPlay ? AppIcons.stopCircle : AppIcons.playCircle,
            color: const Color.fromRGBO(103, 139, 210, 1),
            width: 50,
          ),
        ),
        title: Text(taleModel.title),
        horizontalTitleGap: 20,
        subtitle: Text(
          inclineDuration(taleModel.duration),
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'TTNorms',
            fontWeight: FontWeight.normal,
            color: Color.fromRGBO(58, 58, 85, 0.5),
            letterSpacing: 0.1,
          ),
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: SvgPicture.asset(
            'assets/icons/Trash.svg',
          ),
        ),
      ),
    );
  }
}
