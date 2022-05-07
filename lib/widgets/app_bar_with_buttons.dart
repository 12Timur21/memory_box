import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppBarWithButtons extends StatelessWidget with PreferredSizeWidget {
  const AppBarWithButtons({
    required this.leadingOnPress,
    required this.title,
    this.actionsOnPress,
    this.toolbarHeight,
    Key? key,
  }) : super(key: key);

  final Function leadingOnPress;
  final Widget title;
  final Function? actionsOnPress;
  final double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      primary: true,
      toolbarHeight: toolbarHeight ?? 70,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.only(left: 6),
        child: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/Burger.svg',
          ),
          onPressed: () {
            leadingOnPress();
          },
        ),
      ),
      title: title,
      actions: [
        if (actionsOnPress != null)
          Container(
            margin: const EdgeInsets.only(
              right: 15,
            ),
            child: IconButton(
              onPressed: actionsOnPress!(),
              icon: SvgPicture.asset(
                'assets/icons/More.svg',
              ),
            ),
          )
      ],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? 70);
}
