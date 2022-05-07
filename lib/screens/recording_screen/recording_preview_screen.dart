import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/bottom_navigation_index_control/bottom_navigation_index_control_cubit.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/screens/playlist_screen/add_tale_to_playlists_screen.dart';
import 'package:memory_box/screens/recording_screen/widgets/bottom_sheet_wrapper.dart';
import 'package:memory_box/screens/recording_screen/widgets/tale_controls_buttons.dart';
import 'package:memory_box/widgets/audioSlider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class RecordingPreviewScreen extends StatefulWidget {
  static const routeName = 'RecordingPreviewScreen';

  RecordingPreviewScreen({
    required this.taleModel,
    Key? key,
  }) : super(key: key);

  TaleModel taleModel;

  @override
  _RecordingPreviewScreenState createState() => _RecordingPreviewScreenState();
}

class _RecordingPreviewScreenState extends State<RecordingPreviewScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  bool _isEditMode = false;

  late AudioplayerBloc _audioBloc;

  @override
  void initState() {
    _audioBloc = BlocProvider.of<AudioplayerBloc>(context);
    _audioBloc.add(AnnulAudioPlayer());

    _textEditingController.value = TextEditingValue(
      text: widget.taleModel.title,
    );

    BlocProvider.of<BottomNavigationIndexControlCubit>(context).changeIcon(
      RecorderButtonStates.closeSheet,
    );

    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void closeWindow() {
    Navigator.of(context).pop();
  }

  void changeEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void saveChanges() async {
    if (_textEditingController.text.isEmpty) {
    } else {
      await DatabaseService.instance.updateTale(
        taleID: widget.taleModel.ID,
        title: _textEditingController.text,
      );

      widget.taleModel = widget.taleModel.copyWith(
        title: _textEditingController.text,
      );

      changeEditMode();
    }
  }

  void undoChanges() {
    setState(() {
      _textEditingController.text = widget.taleModel.title;
    });
    changeEditMode();
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

  void _tooglePlay() {
    bool isPlay = _audioBloc.state.isPlay;
    if (isPlay) {
      _audioBloc.add(
        Pause(),
      );
    } else {
      _audioBloc.add(
        Play(
          taleModel: _audioBloc.state.taleModel!,
        ),
      );
    }
  }

  Future<void> _localDownload() async {
    late String downloadDirectory;

    Directory appDirectory = await getApplicationDocumentsDirectory();

    String _pathToSaveAudio = appDirectory.path + '/' + 'Аудиозапись' + '.aac';
    await Directory('/sdcard/Download/MemoryBox').create();

    if (Platform.isAndroid) {
      downloadDirectory =
          '/sdcard/Download/MemoryBox/${widget.taleModel.title}.aac';
    } else {
      return;
    }

    File fileAudio = File(_pathToSaveAudio);

    try {
      await fileAudio.rename(downloadDirectory);
    } on FileSystemException catch (_) {
      await fileAudio.copy(downloadDirectory);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Файл `${widget.taleModel.title}` сохранён в директорию Download/MemoryBox"),
      ),
    );
  }

  Future<void> _deleteTale() async {
    DatabaseService.instance.updateTale(
      taleID: widget.taleModel.ID,
      isDeleted: true,
    );
    Navigator.of(context).pop();
  }

  Future<void> _shareTale() async {
    Share.shareFiles([widget.taleModel.url]);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle popupMenuTextStyle = const TextStyle(
      fontFamily: 'TTNorms',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Colors.black,
    );

    TextStyle editMenuTextStyle = const TextStyle(
      fontFamily: 'TTNorms',
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.black,
    );

    return BottomSheetWrapeer(
      paddingTop: 70,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          right: 30,
          left: 30,
        ),
        child: Column(
          children: [
            _isEditMode
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: undoChanges,
                        child: Text(
                          'Отменить',
                          style: editMenuTextStyle,
                        ),
                      ),
                      TextButton(
                        onPressed: saveChanges,
                        child: Text(
                          'Готово',
                          style: editMenuTextStyle,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: closeWindow,
                        icon: SvgPicture.asset(
                          AppIcons.hideCircle,
                        ),
                      ),
                      PopupMenuButton(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        onSelected: (_) {
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.more,
                            color: Colors.black,
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pushNamed(
                                AddTaleToPlaylists.routeName,
                                arguments: [
                                  widget.taleModel,
                                ],
                              ),
                              child: Text(
                                "Добавить в подборку",
                                style: popupMenuTextStyle,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            child: TextButton(
                              onPressed: changeEditMode,
                              child: Text(
                                "Редактировать название",
                                style: popupMenuTextStyle,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            child: TextButton(
                              onPressed: _shareTale,
                              child: Text(
                                "Поделиться",
                                style: popupMenuTextStyle,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            child: TextButton(
                              onPressed: _localDownload,
                              child: Text(
                                "Скачать",
                                style: popupMenuTextStyle,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            child: TextButton(
                              onPressed: _deleteTale,
                              child: Text(
                                "Удалить",
                                style: popupMenuTextStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              foregroundDecoration: _isEditMode
                  ? BoxDecoration(
                      color: Colors.grey.withOpacity(0.6),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25),
                      ),
                      // backgroundBlendMode: BlendMode.saturation,
                    )
                  : null,
              child: Image.asset(
                'assets/images/cover.png',
                width: 230,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              _isEditMode ? '' : 'Название подборки',
              style: TextStyle(
                color: _isEditMode ? Colors.grey : Colors.black,
                fontFamily: 'TTNorms',
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 60,
              ),
              child: TextField(
                controller: _textEditingController,
                enabled: _isEditMode ? true : false,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontFamily: 'TTNorms',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  isDense: true,
                  border: _isEditMode ? null : InputBorder.none,
                  disabledBorder: _isEditMode
                      ? const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black,
                          ),
                        )
                      : null,
                ),
              ),
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
                      const Spacer(),
                      AudioSlider(
                        onChanged: () {},
                        onChangeEnd: _onSlidedChangeEnd,
                        currentPlayDuration: state.currentPlayPosition,
                        taleDuration: state.taleModel?.duration,
                      ),
                      const Spacer(),
                      TaleControlButtons(
                        tooglePlay: _tooglePlay,
                        moveBackward: _moveBackward,
                        moveForward: _moveForward,
                        isPlay: state.isPlay,
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
