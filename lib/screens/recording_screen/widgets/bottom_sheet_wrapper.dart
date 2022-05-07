import 'package:flutter/material.dart';
import 'package:memory_box/resources/app_coloros.dart';

class BottomSheetWrapeer extends StatelessWidget {
  const BottomSheetWrapeer({
    required this.child,
    this.paddingTop = 130,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final double paddingTop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 5,
        right: 5,
        top: paddingTop,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.silverPhoenix,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 0.3,
            ),
            BoxShadow(
              color: Colors.black,
              offset: Offset(0, 15),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: AppColors.silverPhoenix,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
