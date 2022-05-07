import 'package:flutter/material.dart';
import 'package:memory_box/utils/formatting.dart';

class AudioSlider extends StatefulWidget {
  const AudioSlider({
    required this.onChanged,
    required this.onChangeEnd,
    this.currentPlayDuration,
    this.taleDuration,
    this.primaryColor = Colors.black,
    Key? key,
  }) : super(key: key);

  final VoidCallback onChanged;
  final void Function(double) onChangeEnd;
  final Duration? currentPlayDuration;
  final Duration? taleDuration;
  final Color primaryColor;

  @override
  _AudioSliderState createState() => _AudioSliderState();
}

class _AudioSliderState extends State<AudioSlider> {
  @override
  Widget build(BuildContext context) {
    double sliderTimeValue =
        widget.currentPlayDuration?.inSeconds.toDouble() ?? 0;

    TextStyle numericStyle = TextStyle(
      color: widget.primaryColor,
      fontFamily: 'TTNorms',
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        overlayShape: SliderComponentShape.noOverlay,
        // thumbShape: CustomSliderThumbRhombus(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Slider(
            activeColor: Colors.black,
            inactiveColor: widget.primaryColor,
            max: widget.taleDuration?.inSeconds.toDouble() ?? 0,
            min: 0.0,
            value: sliderTimeValue,
            thumbColor: Colors.red,
            onChanged: (double value) {
              widget.onChanged();
              setState(() {
                sliderTimeValue = value;
              });
            },
            onChangeEnd: (double value) {
              setState(() {
                sliderTimeValue = value;
              });
              widget.onChangeEnd(value);
            },
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                convertDurationToString(
                  duration: widget.currentPlayDuration,
                  formattingType: TimeFormattingType.minuteSecond,
                ),
                style: numericStyle,
              ),
              Text(
                convertDurationToString(
                  duration: widget.taleDuration,
                  formattingType: TimeFormattingType.minuteSecond,
                ),
                style: numericStyle,
              ),
            ],
          )
        ],
      ),
    );
  }
}
