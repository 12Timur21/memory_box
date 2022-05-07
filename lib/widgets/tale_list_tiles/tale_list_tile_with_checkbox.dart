import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/utils/incline.dart';

class TaleListTileWithCheckBox extends StatefulWidget {
  const TaleListTileWithCheckBox({
    required this.taleModel,
    this.isPlay = false,
    this.isSelected = false,
    Key? key,
    required this.toogleSelectMode,
    required this.tooglePlayMode,
  }) : super(key: key);

  final TaleModel taleModel;
  final bool isSelected;
  final bool isPlay;

  final VoidCallback toogleSelectMode;
  final VoidCallback tooglePlayMode;

  @override
  _TaleListTileWithCheckBoxState createState() =>
      _TaleListTileWithCheckBoxState();
}

class _TaleListTileWithCheckBoxState extends State<TaleListTileWithCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.center,
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
          onTap: widget.tooglePlayMode,
          child: SvgPicture.asset(
            widget.isPlay
                ? 'assets/icons/StopCircle.svg'
                : 'assets/icons/PlayCircle.svg',
            color: const Color.fromRGBO(113, 165, 159, 1),
          ),
        ),
        title: Text(widget.taleModel.title),
        horizontalTitleGap: 20,
        subtitle: Text(
          inclineDuration(widget.taleModel.duration),
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'TTNorms',
            fontWeight: FontWeight.normal,
            color: Color.fromRGBO(58, 58, 85, 0.5),
            letterSpacing: 0.1,
          ),
        ),
        trailing: IconButton(
          onPressed: widget.toogleSelectMode,
          icon: widget.isSelected
              ? SvgPicture.asset(
                  'assets/icons/SubmitCircle.svg',
                )
              : SvgPicture.asset(
                  'assets/icons/Circle.svg',
                ),
        ),
      ),
    );
  }
}
