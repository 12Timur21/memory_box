import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

class SoundRecorder {
  String? _pathToSaveAudio;

  FlutterSoundRecorder? _soundRecorder;

  bool _isRecorderInitialised = false;

  Stream<RecordingDisposition>? get recorderStream =>
      _soundRecorder?.onProgress;

  Future<void> init() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    _pathToSaveAudio = appDirectory.path + '/' + 'Аудиозапись' + '.aac';

    try {
      bool isPermissionsReceived = await _checkPermission();
      if (isPermissionsReceived) {
        _soundRecorder = FlutterSoundRecorder();
        _isRecorderInitialised = true;
        await _soundRecorder?.openAudioSession();
        await _soundRecorder?.setSubscriptionDuration(
          const Duration(
            milliseconds: 9,
          ),
        );
      } else {
        openAppSettings();
      }
    } catch (e) {
      dispose();
      log('Failed to open recorder session ');
    }
  }

  Future<void> dispose() async {
    if (_isRecorderInitialised) {
      await _soundRecorder?.closeAudioSession();
      _soundRecorder = null;
    }
  }

  Future<void> startRecording() async {
    if (_isRecorderInitialised) {
      await _soundRecorder?.startRecorder(
        toFile: _pathToSaveAudio,
      );
    }
  }

  Future<void> finishRecording() async {
    if (_isRecorderInitialised) {
      await _soundRecorder?.stopRecorder();
      await dispose();
    }
  }

  Future<bool> _checkPermission() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.storage,
      Permission.microphone,
    ].request();

    bool isGranted = permissions[Permission.storage]!.isGranted &&
        permissions[Permission.microphone]!.isGranted;

    if (isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
