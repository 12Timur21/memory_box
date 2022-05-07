import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/list_builder/list_builder_bloc.dart';
import 'package:memory_box/models/playlist_model.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/repositories/storage_service.dart';

import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/utils/formatting.dart';
import 'package:memory_box/widgets/audioplayer/audio_player.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/tale_list_tiles/tale_list_tile_with_checkbox.dart';
import 'package:memory_box/widgets/tale_list_tiles/tale_list_tile_with_popup_menu.dart';
import 'package:memory_box/widgets/undoButton.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';

class DetailedPlaylistScreen extends StatefulWidget {
  static const routeName = 'DetailedPlaylistScreen';

  DetailedPlaylistScreen({
    required this.playlistModel,
    Key? key,
  }) : super(key: key);

  PlaylistModel playlistModel;

  @override
  _DetailedPlaylistScreenState createState() => _DetailedPlaylistScreenState();
}

enum ScreenMode {
  defaultMode,
  editMode,
  selectMode,
}

class _DetailedPlaylistScreenState extends State<DetailedPlaylistScreen> {
  final _formController = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  ScreenMode _screenMode = ScreenMode.defaultMode;

  late List<TaleModel> _selectedTales;
  File? _currentPlaylistCover, _selectedPlaylistCover;

  @override
  void initState() {
    _selectedTales = [...widget.playlistModel.taleModels];

    _titleController.value = TextEditingValue(text: widget.playlistModel.title);
    if (widget.playlistModel.description != null) {
      _descriptionController.value =
          TextEditingValue(text: widget.playlistModel.description!);
    }

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _undoEditChanges() {
    setState(() {
      if (_formController.currentState!.validate()) {
        _titleController.value =
            TextEditingValue(text: widget.playlistModel.title);

        if (widget.playlistModel.description != null) {
          _descriptionController.value =
              TextEditingValue(text: widget.playlistModel.description!);
        }
      }
      if (_selectedPlaylistCover != null) {
        _selectedPlaylistCover = _currentPlaylistCover;
      }
      _selectedPlaylistCover = null;
      _screenMode = ScreenMode.defaultMode;
    });
  }

  void _saveEditChanges() async {
    if (_formController.currentState?.validate() ?? false) {
      if (_selectedPlaylistCover != null) {
        _currentPlaylistCover = _selectedPlaylistCover;
        await StorageService.instance.uploadPlayListCover(
          coverID: widget.playlistModel.ID,
          file: _currentPlaylistCover!,
        );
      }

      setState(() {
        widget.playlistModel = widget.playlistModel.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
        );

        _screenMode = ScreenMode.defaultMode;
      });

      DatabaseService.instance.updatePlaylist(
        playlistID: widget.playlistModel.ID,
        title: _titleController.text,
        description: _descriptionController.text,
      );
    }
  }

  void _toogleTaleSelectMode(TaleModel taleModel) {
    final bool isHasAlreadySelected = _selectedTales.contains(taleModel);

    setState(() {
      if (isHasAlreadySelected) {
        _selectedTales.remove(taleModel);
      } else {
        _selectedTales.add(taleModel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListBuilderBloc>(
          create: (_) => ListBuilderBloc()
            ..add(
              InitializeListBuilderWithTaleModels(
                _selectedTales,
              ),
            ),
        ),
        BlocProvider<AudioplayerBloc>(
          create: (_) => AudioplayerBloc()
            ..add(
              InitPlayer(),
            ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BackgroundPattern(
            patternColor: AppColors.seaNymph,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                primary: true,
                toolbarHeight: 70,
                backgroundColor: Colors.transparent,
                centerTitle: true,
                leading: UndoButton(
                  undoChanges: () {
                    if (_screenMode == ScreenMode.editMode) {
                      _undoEditChanges();
                    } else if (_screenMode == ScreenMode.selectMode) {
                      context.read<ListBuilderBloc>().add(
                            InitializeListBuilderWithTaleModels(
                              [...widget.playlistModel.taleModels],
                            ),
                          );
                      setState(() {
                        _screenMode = ScreenMode.defaultMode;
                        _selectedTales = [...widget.playlistModel.taleModels];
                      });
                    } else {
                      Navigator.of(context).pop(
                        widget.playlistModel,
                      );
                    }
                  },
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                      right: 15,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_screenMode == ScreenMode.editMode) ...[
                          TextButton(
                            onPressed: _saveEditChanges,
                            child: const Text(
                              'Сохранить изменения',
                              style: TextStyle(
                                fontFamily: 'TTNorms',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ] else if (_screenMode == ScreenMode.selectMode) ...[
                          _SelectPopUpMenuButton(
                            playlistModel: widget.playlistModel,
                            selectedTales: _selectedTales,
                            onScreenModeChanged: (ScreenMode screenMode) {
                              setState(() {
                                _screenMode = screenMode;
                              });
                            },
                            onPlaylistModelChanged:
                                (PlaylistModel playlistModel) {
                              widget.playlistModel = playlistModel;
                            },
                            onSelectedTaleListChanged:
                                (List<TaleModel> updatedSelectedTales) {
                              setState(() {
                                _selectedTales = updatedSelectedTales;
                              });
                            },
                          )
                        ] else ...[
                          _PopUpMenuButton(
                            onScreenModeChanges: (ScreenMode screenMode) {
                              setState(() {
                                _screenMode = screenMode;
                              });
                            },
                            playlistID: widget.playlistModel.ID,
                          ),
                        ],
                      ],
                    ),
                  )
                ],
                elevation: 0,
              ),
              body: Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Form(
                    key: _formController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          enabled: _screenMode == ScreenMode.editMode,
                          controller: _titleController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Пожалуйста, введите название подборки';
                            }

                            if (text.length > 20) {
                              return 'Слишком длинное название';
                            }

                            return null;
                          },
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Название...',
                            border: _screenMode == ScreenMode.editMode
                                ? null
                                : InputBorder.none,
                            hintStyle: const TextStyle(
                              fontFamily: 'TTNorms',
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        _PlaylistCover(
                          screenMode: _screenMode,
                          playlistModel: widget.playlistModel,
                          playlistTaleModels: _selectedTales,
                          playlistCoverFile: _selectedPlaylistCover,
                          onPickUpImage: (File image) {
                            setState(() {
                              _selectedPlaylistCover = image;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        _Description(
                          isEditMode: _screenMode == ScreenMode.editMode,
                          controller: _descriptionController,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 300,
                          child: _ListBuilder(
                            scrollController: _scrollController,
                            selectedTales: _selectedTales,
                            onSelect: _toogleTaleSelectMode,
                            screenMode: _screenMode,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectPopUpMenuButton extends StatelessWidget {
  const _SelectPopUpMenuButton({
    required this.onScreenModeChanged,
    required this.onSelectedTaleListChanged,
    required this.selectedTales,
    required this.playlistModel,
    required this.onPlaylistModelChanged,
    Key? key,
  }) : super(key: key);

  final Function(ScreenMode) onScreenModeChanged;
  final Function(List<TaleModel>) onSelectedTaleListChanged;
  final List<TaleModel> selectedTales;

  final PlaylistModel playlistModel;
  final Function(PlaylistModel) onPlaylistModelChanged;

  final TextStyle _popupMenuTextStyle = const TextStyle(
    fontFamily: 'TTNorms',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: Colors.black,
  );

  void _cancelSelect(BuildContext context) {
    context.read<ListBuilderBloc>().add(
          InitializeListBuilderWithTaleModels(
            [...playlistModel.taleModels],
          ),
        );
    onSelectedTaleListChanged([...playlistModel.taleModels]);
    onScreenModeChanged(ScreenMode.defaultMode);
  }

  void _saveSelectedTales(BuildContext context) {
    DatabaseService.instance.updatePlaylist(
      playlistID: playlistModel.ID,
      taleModels: selectedTales,
    );

    context.read<ListBuilderBloc>().add(
          InitializeListBuilderWithTaleModels(
            selectedTales,
          ),
        );

    onPlaylistModelChanged(
      playlistModel.copyWith(
        taleModels: selectedTales,
      ),
    );
    onScreenModeChanged(ScreenMode.defaultMode);
  }

  Future<void> _shareFiles() async {
    List<String> listFiles = [];
    final Directory appDirectory = await getApplicationDocumentsDirectory();

    for (TaleModel taleModel in selectedTales) {
      final ref = StorageService.instance.createTaleReference(taleModel.ID);

      final _pathToSaveAudio = '${appDirectory.path}/${taleModel.title}.aac';

      File file = File(_pathToSaveAudio);
      DownloadTask downloadTask = ref.writeToFile(file);

      await downloadTask.whenComplete(
        () => listFiles.add(file.path),
      );
    }
    Share.shareFiles(listFiles);
  }

  Future<void> _localSaveSelectedTales() async {
    await Directory('/sdcard/Download/MemoryBox').create();

    for (TaleModel taleModel in selectedTales) {
      Reference ref = StorageService.instance.createTaleReference(taleModel.ID);

      File file = File('/sdcard/Download/MemoryBox/${taleModel.title}.aac');
      ref.writeToFile(file);
    }
  }

  void _unselectSelectedTales(BuildContext context) {
    DatabaseService.instance.updatePlaylist(
      playlistID: playlistModel.ID,
      taleModels: [],
    );

    context.read<ListBuilderBloc>().add(
          InitializeListBuilderWithTaleModels(
            [],
          ),
        );

    onSelectedTaleListChanged(
      [],
    );

    onPlaylistModelChanged(
      playlistModel.copyWith(
        taleModels: [],
      ),
    );

    onScreenModeChanged(
      ScreenMode.defaultMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.more,
          color: Colors.white,
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            _cancelSelect(context);
          },
          child: Text(
            "Отменить выбор",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: () {
            _saveSelectedTales(context);
          },
          child: Text(
            "Добавить в подборку",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: () {
            _shareFiles();
          },
          child: Text(
            "Поделиться ",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: () {
            _localSaveSelectedTales();
          },
          child: Text(
            "Скачать все",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: () {
            _unselectSelectedTales(context);
          },
          child: Text(
            "Удалить все",
            style: _popupMenuTextStyle,
          ),
        ),
      ],
    );
  }
}

class _PopUpMenuButton extends StatelessWidget {
  const _PopUpMenuButton({
    required this.onScreenModeChanges,
    required this.playlistID,
    Key? key,
  }) : super(key: key);

  final String playlistID;
  final Function(ScreenMode) onScreenModeChanges;

  final TextStyle _popupMenuTextStyle = const TextStyle(
    fontFamily: 'TTNorms',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.more,
          color: Colors.white,
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            onScreenModeChanges(ScreenMode.editMode);
          },
          child: Text(
            "Редактировать",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: () {
            context.read<ListBuilderBloc>().add(
                  InitializeListBuilderWithFutureRequest(
                    talesInitRequest:
                        DatabaseService.instance.getAllNotDeletedTaleModels(),
                  ),
                );

            onScreenModeChanges(ScreenMode.selectMode);
          },
          child: Text(
            "Выделить несколько",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: () {
            DatabaseService.instance.deletePlayList(
              playListID: playlistID,
            );
            Navigator.of(context).pop();
          },
          child: Text(
            "Удалить подборку",
            style: _popupMenuTextStyle,
          ),
        ),
      ],
    );
  }
}

class _PlaylistCover extends StatelessWidget {
  const _PlaylistCover({
    required this.screenMode,
    required this.playlistModel,
    this.playlistCoverFile,
    required this.playlistTaleModels,
    required this.onPickUpImage,
    Key? key,
  }) : super(key: key);

  final ScreenMode screenMode;
  final PlaylistModel playlistModel;
  final File? playlistCoverFile;
  final List<TaleModel> playlistTaleModels;
  final Function(File) onPickUpImage;

  Future<void> _pickImage() async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    String? path = pickedImage?.path;
    if (path != null) {
      onPickUpImage(
        File(path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int talesLength = playlistTaleModels.length;
    final Duration talesSumDuration = playlistTaleModels.fold<Duration>(
      Duration.zero,
      (Duration previousValue, element) => previousValue + element.duration,
    );

    TextStyle _playlistCoverTextStyle = const TextStyle(
      fontFamily: 'TTNorms',
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.white,
    );

    return GestureDetector(
      onTap: screenMode == ScreenMode.editMode ? _pickImage : null,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.wildSand.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 20,
              color: Colors.black.withOpacity(0.25),
            ),
          ],
        ),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: playlistCoverFile == null
                    ? Image.network(
                        playlistModel.coverUrl,
                        fit: BoxFit.fitWidth,
                      )
                    : Image.file(
                        playlistCoverFile!,
                        fit: BoxFit.fitWidth,
                      ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withOpacity(0),
                    AppColors.gray,
                  ],
                ),
              ),
            ),
            if (screenMode == ScreenMode.editMode)
              Center(
                child: SvgPicture.asset(
                  AppIcons.chosePhoto,
                  color: Colors.black,
                ),
              ),
            if (screenMode != ScreenMode.editMode)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          convertDateTimeToString(
                            date: playlistModel.creation_date,
                            dayTimeFormattingType:
                                DayTimeFormattingType.dayMonthYear,
                          ),
                          style: _playlistCoverTextStyle,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$talesLength аудио',
                              style: _playlistCoverTextStyle,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${convertDurationToString(
                                duration: talesSumDuration,
                                formattingType: TimeFormattingType.hourMinute,
                              )} часов',
                              style: _playlistCoverTextStyle,
                            ),
                          ],
                        )
                      ],
                    ),
                    if (screenMode != ScreenMode.selectMode)
                      BlocBuilder<ListBuilderBloc, ListBuilderState>(
                        builder: (context, state) {
                          final listBuilderBloc =
                              context.read<ListBuilderBloc>();
                          return Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () {
                                listBuilderBloc.add(
                                  TooglePlayAllMode(),
                                );
                              },
                              child: Container(
                                width: 168,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.wildSand.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: SvgPicture.asset(
                                        listBuilderBloc.state.isPlayAllTalesMode
                                            ? AppIcons.stopCircle
                                            : AppIcons.playCircle,
                                        width: 45,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    listBuilderBloc.state.isPlayAllTalesMode
                                        ? const Text(
                                            'Остановить',
                                            style: TextStyle(
                                              fontFamily: 'TTNorms',
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Запустить все',
                                            style: TextStyle(
                                              fontFamily: 'TTNorms',
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.isEditMode,
    required this.controller,
    Key? key,
  }) : super(key: key);

  final bool isEditMode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return TextFormField(
        style: const TextStyle(
          fontFamily: 'TTNorms',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Введите описание...',
          focusColor: Colors.red,
        ),
        validator: (text) {
          if (text != null && text.length > 400) {
            return 'Слишком длинное название';
          }

          return null;
        },
        maxLines: null,
        minLines: 1,
      );
    }

    return ReadMoreText(
      controller.text,
      trimLines: 5,
      colorClickableText: Colors.pink,
      trimMode: TrimMode.Line,
      trimCollapsedText: 'Подробнее',
      trimExpandedText: 'Свернуть',
      style: const TextStyle(
        fontFamily: 'TTNorms',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      moreStyle: const TextStyle(
        fontFamily: 'TTNorms',
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: AppColors.darkPurple,
      ),
      lessStyle: const TextStyle(
        fontFamily: 'TTNorms',
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: AppColors.darkPurple,
      ),
    );
  }
}

class _ListBuilder extends StatelessWidget {
  const _ListBuilder({
    required this.scrollController,
    required this.selectedTales,
    required this.screenMode,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController;
  final List<TaleModel> selectedTales;
  final ScreenMode screenMode;
  final Function(TaleModel) onSelect;

  void _scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final listBuilderBloc = context.read<ListBuilderBloc>();
    final audioPlayerBloc = context.read<AudioplayerBloc>();

    return BlocConsumer<ListBuilderBloc, ListBuilderState>(
      listener: (context, state) {
        if (state is PlayTaleState) {
          final TaleModel taleModel = state.currentPlayTaleModel!;
          audioPlayerBloc.add(
            Play(
              taleModel: taleModel,
              isAutoPlay: true,
            ),
          );
        }

        if (state is StopTaleState) {
          audioPlayerBloc.add(
            Pause(),
          );
        }
      },
      builder: (context, listBuilderState) {
        return Stack(
          children: [
            ListView.builder(
              itemCount: listBuilderState.allTales.length + 1,
              itemBuilder: (context, index) {
                if (listBuilderState.allTales.length == index) {
                  return const SizedBox(
                    height: 90,
                  );
                }

                TaleModel taleModel = listBuilderState.allTales[index];
                bool isPlayMode = false;

                if (listBuilderState.currentPlayTaleModel == taleModel &&
                    listBuilderState.isPlay) {
                  isPlayMode = true;
                }

                if (screenMode == ScreenMode.selectMode) {
                  return TaleListTileWithCheckBox(
                    key: UniqueKey(),
                    isPlay: isPlayMode,
                    isSelected: selectedTales.contains(
                      taleModel,
                    ),
                    taleModel: taleModel,
                    tooglePlayMode: () {
                      _scrollDown();
                      listBuilderBloc.add(
                        TooglePlayMode(
                          taleModel: taleModel,
                        ),
                      );
                    },
                    toogleSelectMode: () {
                      onSelect(taleModel);
                    },
                  );
                }

                return TaleListTileWithPopupMenu(
                  key: UniqueKey(),
                  isPlayMode: isPlayMode,
                  taleModel: taleModel,
                  playButtonColor: AppColors.seaNymph,
                  onAddToPlaylist: () {},
                  onDelete: () {
                    listBuilderBloc.add(
                      DeleteTale(taleModel),
                    );
                  },
                  onRename: (String newTitle) {
                    listBuilderBloc.add(
                      RenameTale(
                        taleModel.ID,
                        newTitle,
                      ),
                    );
                  },
                  onShare: () {
                    Share.share(taleModel.url);
                  },
                  onUndoRenaming: () {
                    listBuilderBloc.add(
                      UndoRenameTale(),
                    );
                  },
                  tooglePlayMode: () {
                    _scrollDown();
                    listBuilderBloc.add(
                      TooglePlayMode(
                        taleModel: taleModel,
                      ),
                    );
                  },
                );
              },
            ),
            if (screenMode == ScreenMode.editMode)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.wildSand.withOpacity(0.4),
              ),
            const _AudioPlayer(),
          ],
        );
      },
    );
  }
}

class _AudioPlayer extends StatelessWidget {
  const _AudioPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listBuilderBloc = context.read<ListBuilderBloc>();
    final audioPlayerBloc = context.read<AudioplayerBloc>();

    return BlocConsumer<AudioplayerBloc, AudioplayerState>(
      listener: (context, state) {
        if (state.isTaleEnd) {
          if (listBuilderBloc.state.isPlayAllTalesMode) {
            listBuilderBloc.add(
              NextTale(),
            );
          } else {
            listBuilderBloc.add(
              TooglePlayMode(),
            );
            audioPlayerBloc.add(
              AnnulAudioPlayer(),
            );
          }
        }
      },
      builder: (context, state) {
        if (state.isTaleInit) {
          return Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            child: AudioPlayer(
              taleModel: state.taleModel,
              currentPlayPosition: state.currentPlayPosition,
              isPlay: listBuilderBloc.state.isPlay,
              tooglePlayMode: () {
                listBuilderBloc.add(
                  TooglePlayMode(
                    taleModel: state.taleModel,
                  ),
                );
              },
              onSliderChangeEnd: (value) {
                audioPlayerBloc.add(
                  Seek(currentPlayTimeInSec: value),
                );
              },
              onSliderChanged: () => {},
              next: () {
                listBuilderBloc.add(
                  NextTale(),
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }
}
