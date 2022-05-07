import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UndoButton extends StatelessWidget {
  const UndoButton({
    required this.undoChanges,
    Key? key,
  }) : super(key: key);
  final VoidCallback undoChanges;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10),
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(
            15,
          ),
        ),
      ),
      child: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/ArrowLeftCircle.svg',
        ),
        onPressed: undoChanges,
      ),
    );
  }
}
