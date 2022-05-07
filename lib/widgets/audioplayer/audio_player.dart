import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/widgets/audioSlider.dart';

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({
    this.taleModel,
    this.isPlay = false,
    required this.currentPlayPosition,
    this.next,
    required this.tooglePlayMode,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
    this.isNextButtonAvalible = true,
    Key? key,
  }) : super(key: key);

  final TaleModel? taleModel;
  final bool isPlay;
  final Duration? currentPlayPosition;

  final VoidCallback tooglePlayMode;

  final VoidCallback onSliderChanged;
  final Function(double) onSliderChangeEnd;
  final VoidCallback? next;

  final bool isNextButtonAvalible;

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.amber,
        gradient: LinearGradient(
          colors: [
            AppColors.blueMagenta,
            AppColors.kimberly,
          ],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(71),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: widget.tooglePlayMode,
              padding: const EdgeInsets.all(0),
              alignment: Alignment.center,
              icon: SvgPicture.asset(
                widget.isPlay ? AppIcons.stopCircle : AppIcons.playCircle,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.taleModel!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'TTNorms',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AudioSlider(
                      onChanged: widget.onSliderChanged,
                      onChangeEnd: (value) => widget.onSliderChangeEnd(value),
                      currentPlayDuration: widget.currentPlayPosition,
                      taleDuration: widget.taleModel!.duration,
                      primaryColor: Colors.white,
                    )
                  ],
                ),
              ),
            ),
            widget.isNextButtonAvalible
                ? Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    child: GestureDetector(
                      onTap: widget.next,
                      child: SvgPicture.asset(
                        AppIcons.arrowNext,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
