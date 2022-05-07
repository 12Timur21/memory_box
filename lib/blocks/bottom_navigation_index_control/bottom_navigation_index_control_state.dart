part of 'bottom_navigation_index_control_cubit.dart';

enum RecorderButtonStates {
  defaultIcon,
  withIcon,
  withLine,
  closeSheet,
}

class BottomNavigationIndexControlState {
  int index;

  RecorderButtonStates recorderButtonState;

  BottomNavigationIndexControlState(
    this.index, {
    this.recorderButtonState = RecorderButtonStates.withIcon,
  });
}
