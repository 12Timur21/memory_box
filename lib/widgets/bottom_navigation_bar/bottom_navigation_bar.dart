import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/blocks/bottom_navigation_index_control/bottom_navigation_index_control_cubit.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/screens/all_tales_screen/all_tales_screen.dart';
import 'package:memory_box/screens/home_screen/home_screen.dart';
import 'package:memory_box/screens/mainPage.dart';
import 'package:memory_box/screens/playlist_screen/playlist_screen.dart';
import 'package:memory_box/screens/profile_screen/profile_screen.dart';
import 'package:memory_box/widgets/bottom_navigation_bar/widgets/recorder_buttons_barrel.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    required this.openButtomSheet,
    Key? key,
  }) : super(key: key);

  final Function openButtomSheet;
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  RecorderButtonStates _iconState = RecorderButtonStates.withIcon;

  void _onBottomNavigatorTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      MainPage.navigationKey.currentState
          ?.pushReplacementNamed(HomeScreen.routeName);
    }
    if (index == 1) {
      MainPage.navigationKey.currentState
          ?.pushReplacementNamed(PlaylistScreen.routeName);
    }
    if (index == 2) {
      if (_iconState == RecorderButtonStates.withIcon) {
        widget.openButtomSheet();
      }
      if (_iconState == RecorderButtonStates.closeSheet) {
        Navigator.of(context).pop();
      }
    }
    if (index == 3) {
      MainPage.navigationKey.currentState
          ?.pushReplacementNamed(AllTalesScreen.routeName);
    }
    if (index == 4) {
      MainPage.navigationKey.currentState
          ?.pushReplacementNamed(ProfileScreen.routeName);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getIcon(RecorderButtonStates recorderButtonState) {
    if (recorderButtonState == RecorderButtonStates.withIcon) {
      return const RecorderButtonWithIcon();
    }
    if (recorderButtonState == RecorderButtonStates.withLine) {
      return const RecorderButtonWithLine();
    }
    if (recorderButtonState == RecorderButtonStates.defaultIcon) {
      return const DefaultRecorderButton();
    }
    return const RecorderButtonClose();
  }

  @override
  Widget build(BuildContext context) {
    BottomNavigationBarItem _bottomNavigationBarItem({
      required String iconName,
      required String label,
      bool isSelected = false,
    }) {
      return BottomNavigationBarItem(
        icon: Column(
          children: [
            SvgPicture.asset(
              iconName,
              color: isSelected ? AppColors.blueMagenta : null,
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'TTNorms',
                fontWeight: FontWeight.normal,
                fontSize: 11,
                color: isSelected ? AppColors.blueMagenta : null,
              ),
            )
          ],
        ),
        label: '',
      );
    }

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 0,
                blurRadius: 10,
              ),
            ],
          ),
          child: BlocListener<BottomNavigationIndexControlCubit,
              BottomNavigationIndexControlState>(
            listener: (context, state) {
              setState(() {
                _selectedIndex = state.index;
                _iconState = state.recorderButtonState;
              });
            },
            child: BottomNavigationBar(
              backgroundColor: AppColors.wildSand,
              type: BottomNavigationBarType.fixed,
              onTap: _onBottomNavigatorTapped,
              selectedItemColor: AppColors.darkPurple,
              selectedLabelStyle: const TextStyle(
                color: AppColors.tacao,
                fontFamily: 'TTNorms',
                fontWeight: FontWeight.normal,
                fontSize: 10,
              ),
              items: <BottomNavigationBarItem>[
                _bottomNavigationBarItem(
                  iconName: AppIcons.home,
                  label: 'Главная',
                  isSelected: _selectedIndex == 0,
                ),
                _bottomNavigationBarItem(
                  iconName: AppIcons.category,
                  label: 'Подборки',
                  isSelected: _selectedIndex == 1,
                ),
                BottomNavigationBarItem(
                  icon: _getIcon(_iconState),
                  label: '',
                ),
                _bottomNavigationBarItem(
                  iconName: AppIcons.document,
                  label: 'Аудиозаписи',
                  isSelected: _selectedIndex == 3,
                ),
                _bottomNavigationBarItem(
                  iconName: AppIcons.profile,
                  label: 'Профиль',
                  isSelected: _selectedIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
