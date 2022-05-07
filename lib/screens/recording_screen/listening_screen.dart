import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/bottom_navigation_index_control/bottom_navigation_index_control_cubit.dart';
import 'package:memory_box/blocks/session/session_bloc.dart';

import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/storage_service.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/screens/mainPage.dart';
import 'package:memory_box/screens/recording_screen/recording_preview_screen.dart';
import 'package:memory_box/screens/recording_screen/widgets/bottom_sheet_wrapper.dart';
import 'package:memory_box/screens/recording_screen/widgets/tale_controls_buttons.dart';
import 'package:memory_box/widgets/audioSlider.dart';
import 'package:memory_box/widgets/deleteAlert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class ListeningScreen extends StatefulWidget {
  static const routeName = 'ListeningScreen';

  const ListeningScreen({Key? key}) : super(key: key);
  @override
  _ListeningScreenState createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  late AudioplayerBloc _audioBloc;
  String? _pathToSaveAudio;

  bool _isScreenInitialized = false;
  String _taleTitle = 'Запись №';

  @override
  void initState() {
    _audioBloc = BlocProvider.of<AudioplayerBloc>(context);

    _changeRecordingButton();
    _asyncInit();

    super.initState();
  }

  void _asyncInit() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();

    _pathToSaveAudio = appDirectory.path + '/' + 'Аудиозапись' + '.aac';

    TaleModel _taleModel = TaleModel(
      url: _pathToSaveAudio!,
      title: 'Запись №',
      ID: const Uuid().v4(),
      duration: Duration.zero,
    );

    _audioBloc.add(InitPlayer());
    _audioBloc.add(
      InitTale(
        taleModel: _taleModel,
        isAutoPlay: false,
      ),
    );

    int index = await StorageService.instance.filesLength(
      fileType: FileType.tale,
    );

    setState(() {
      _taleTitle = 'Запись №$index';
      _isScreenInitialized = true;
    });
  }

  void _tooglePlay() {
    bool _isPlay = context.read<AudioplayerBloc>().state.isPlay;
    if (_isPlay == false) {
      _audioBloc.add(
        Play(
          taleModel: _audioBloc.state.taleModel!,
        ),
      );
    } else {
      _audioBloc.add(
        Pause(),
      );
    }
  }

  void _shareSound() {
    Share.shareFiles([_pathToSaveAudio!]);
  }

  void _changeRecordingButton() {
    BlocProvider.of<BottomNavigationIndexControlCubit>(context).changeIcon(
      RecorderButtonStates.defaultIcon,
    );
  }

  void _localDownloadSound() async {
    late String downloadDirectory;

    await Directory('/sdcard/Download/MemoryBox').create();

    if (Platform.isAndroid) {
      downloadDirectory = '/sdcard/Download/MemoryBox/$_taleTitle.aac';
    } else {
      return;
    }

    File fileAudio = File(_pathToSaveAudio!);

    try {
      await fileAudio.rename(downloadDirectory);
    } on FileSystemException catch (_) {
      await fileAudio.copy(downloadDirectory);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Файл `$_taleTitle` сохранён в директорию Download/MemoryBox"),
      ),
    );
  }

  void _deleteSound() async {
    bool? isDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const DeleteAlert(
          title: 'Удалить эту аудиозапись?',
          content: 'Вы действительно хотите удалить аудиозапись?',
        );
      },
    );
    if (isDelete == true) {
      Directory(_pathToSaveAudio!).deleteSync(recursive: true);

      Navigator.of(context).pop();
    }
  }

  void _saveSound() async {
    if (context.read<SessionBloc>().state.status !=
        SessionStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Сохранение в облако доступно только авторизованным пользователям, но у вас есть возможность локального сохранения",
          ),
        ),
      );
      return;
    }

    final File file = File(_pathToSaveAudio!);
    TaleModel? updatedTaleModel = _audioBloc.state.taleModel?.copyWith(
      title: _taleTitle,
    );

    setState(() {
      _isScreenInitialized = false;
    });

    await StorageService.instance.uploadTaleFile(
      file: file,
      taleModel: updatedTaleModel!,
    );

    MainPage.recordingNavigatorKey.currentState?.pushNamed(
      RecordingPreviewScreen.routeName,
      arguments: updatedTaleModel,
    );
  }

  void _moveBackward() {
    _audioBloc.add(
      MoveBackward15Sec(),
    );
  }

  void _moveForward() {
    _audioBloc.add(
      MoveForward15Sec(),
    );
  }

  void _onSlidedChangeEnd(double value) {
    _audioBloc.add(
      Seek(currentPlayTimeInSec: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetWrapeer(
      child: _isScreenInitialized == false
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.only(
                top: 20,
                right: 30,
                left: 30,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            padding: const EdgeInsets.only(right: 20),
                            onPressed: _shareSound,
                            icon: SvgPicture.asset(
                              AppIcons.share,
                            ),
                          ),
                          IconButton(
                            onPressed: _localDownloadSound,
                            icon: SvgPicture.asset(
                              AppIcons.paperDownload,
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.only(left: 20),
                            onPressed: _deleteSound,
                            icon: SvgPicture.asset(
                              AppIcons.delete,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _saveSound,
                        child: const Text(
                          'Сохранить',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'TTNorms',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 90,
                  ),
                  Expanded(
                    child: BlocBuilder<AudioplayerBloc, AudioplayerState>(
                      builder: (context, state) {
                        if (state.isTaleEnd) {
                          context.read<AudioplayerBloc>().add(
                                AnnulAudioPlayer(),
                              );
                        }
                        return Column(
                          children: [
                            Text(
                              _taleTitle,
                              style: const TextStyle(
                                fontFamily: 'TTNorms',
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            Expanded(
                              child: AudioSlider(
                                onChanged: () {},
                                onChangeEnd: _onSlidedChangeEnd,
                                currentPlayDuration: state.currentPlayPosition,
                                taleDuration: state.taleModel?.duration,
                              ),
                            ),
                            TaleControlButtons(
                              isPlay: state.isPlay,
                              tooglePlay: _tooglePlay,
                              moveBackward: _moveBackward,
                              moveForward: _moveForward,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
