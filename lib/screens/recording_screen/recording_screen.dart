import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:memory_box/blocks/bottom_navigation_index_control/bottom_navigation_index_control_cubit.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/screens/mainPage.dart';
import 'package:memory_box/screens/recording_screen/listening_screen.dart';
import 'package:memory_box/screens/recording_screen/widgets/bottom_sheet_wrapper.dart';
import 'package:memory_box/screens/recording_screen/widgets/visualizer.dart';
import 'dart:async';
import 'dart:math';

import 'package:memory_box/services/soundRecorder.dart';
import 'package:memory_box/utils/formatting.dart';

class RecordingScreen extends StatefulWidget {
  static const routeName = 'RecordingScreen';

  const RecordingScreen({Key? key}) : super(key: key);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final SoundRecorder _recorder = SoundRecorder();
  Stream<RecordingDisposition>? _recorderSubscription;

  int taleDurationInSecond = 0;

  @override
  void initState() {
    changeRecordingButton();
    asyncInit();
    super.initState();
  }

  void asyncInit() async {
    try {
      await _recorder.init();
      startRecording();

      setState(() {
        _recorderSubscription = _recorder.recorderStream?.asBroadcastStream();
      });
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    await _recorder.startRecording();
  }

  Future<void> finishRecording() async {
    if (taleDurationInSecond == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Длительность сказки не может быть меньше 1 секунды"),
        ),
      );
    } else {
      await _recorder.finishRecording();
      MainPage.recordingNavigatorKey.currentState?.pushReplacementNamed(
        ListeningScreen.routeName,
      );
    }
  }

  void changeRecordingButton() {
    BlocProvider.of<BottomNavigationIndexControlCubit>(context).changeIcon(
      RecorderButtonStates.withLine,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetWrapeer(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                right: 30,
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Отменить',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'TTNorms',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: startRecording,
              child: const Text(
                'Запись',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'TTNorms',
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          Expanded(
            child: Transform.rotate(
              angle: -pi,
              child: Visualizer(
                recorderSubscription: _recorderSubscription,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(
                  right: 5,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.appleBlossom,
                  shape: BoxShape.circle,
                ),
              ),
              StreamBuilder<RecordingDisposition>(
                  stream: _recorderSubscription,
                  builder: (context, snapshot) {
                    taleDurationInSecond =
                        snapshot.data?.duration.inSeconds ?? 0;

                    return Text(
                      convertDurationToString(
                        duration: snapshot.data?.duration,
                        formattingType: TimeFormattingType.hourMinuteSecond,
                      ),
                      style: const TextStyle(
                        fontFamily: 'TTNorms',
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    );
                  }),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: finishRecording,
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: const Icon(
                    Icons.pause_circle,
                    color: AppColors.tacao,
                    size: 80,
                  ),
                ),
              ),
              Container(
                color: AppColors.tacao,
                width: 5,
                height: 30,
              )
            ],
          ),
        ],
      ),
    );
  }
}
