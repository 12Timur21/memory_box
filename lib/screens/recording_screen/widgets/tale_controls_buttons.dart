import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TaleControlButtons extends StatefulWidget {
  const TaleControlButtons({
    Key? key,
    required this.tooglePlay,
    required this.moveBackward,
    required this.moveForward,
    required this.isPlay,
  }) : super(key: key);

  final Function tooglePlay;
  final Function moveForward;
  final Function moveBackward;
  final bool isPlay;

  @override
  _TaleControlButtonsState createState() => _TaleControlButtonsState();
}

class _TaleControlButtonsState extends State<TaleControlButtons> {
  bool isPlayMode = false;

  @override
  void initState() {
    super.initState();
  }

  void tooglePlay() {
    widget.tooglePlay();
  }

  void moveForward() {
    widget.moveForward();
  }

  void moveBackward() {
    widget.moveBackward();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            moveBackward();
          },
          icon: SvgPicture.asset(
            'assets/icons/15SecAgo.svg',
          ),
        ),
        const SizedBox(
          width: 30,
        ),
        GestureDetector(
          onTap: tooglePlay,
          child: widget.isPlay
              ? const Icon(
                  Icons.pause_circle,
                  color: Color.fromRGBO(241, 180, 136, 1),
                  size: 80,
                )
              : const Icon(
                  Icons.play_circle,
                  color: Color.fromRGBO(241, 180, 136, 1),
                  size: 80,
                ),
        ),
        const SizedBox(
          width: 30,
        ),
        IconButton(
          onPressed: () {
            moveForward();
          },
          icon: SvgPicture.asset('assets/icons/15SecAfter.svg'),
        ),
      ],
    );
  }
}
