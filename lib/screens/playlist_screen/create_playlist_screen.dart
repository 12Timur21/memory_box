import 'dart:developer';
import 'dart:io';
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
import 'package:memory_box/screens/playlist_screen/select_tales_to_playlist_screen.dart';
import 'package:memory_box/widgets/audioplayer/audio_player.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/tale_list_tiles/tale_list_tile_with_popup_menu.dart';
import 'package:memory_box/widgets/undoButton.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class CreatePlaylistScreen extends StatefulWidget {
  static const routeName = 'CreatePlaylistScreen';

  const CreatePlaylistScreen({Key? key}) : super(key: key);

  @override
  _CreatePlaylistScreenState createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _formController = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isImageValid = true;
  File? _playlistCover;

  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  bool _validateImageField() {
    setState(() {
      if (_playlistCover != null) {
        _isImageValid = true;
      } else {
        _isImageValid = false;
      }
    });

    return _isImageValid;
  }

  Future<void> _saveCollection({
    required List<TaleModel> allTales,
  }) async {
    final bool _isImageValid = _validateImageField();
    log(_isImageValid.toString());

    if (_formController.currentState!.validate() && _isImageValid) {
      setState(() {
        isLoading = true;
      });
      String playlistID = const Uuid().v4();

      String coverUrl = await StorageService.instance.uploadPlayListCover(
        file: _playlistCover!,
        coverID: playlistID,
      );

      PlaylistModel _playlistModel =
          await DatabaseService.instance.createPlaylist(
        playlistID: playlistID,
        title: _titleController.text,
        description: _descriptionController.text,
        talesModels: allTales,
        coverUrl: coverUrl,
      );

      Navigator.of(context).pop(_playlistModel);
    }
  }

  void _pop() {
    Navigator.of(context).pop();
  }

  Future<void> _addTales({
    required BuildContext context,
  }) async {
    final listBuilderBloc = context.read<ListBuilderBloc>();

    if (listBuilderBloc.state.currentPlayTaleModel != null &&
        listBuilderBloc.state.isPlay) {
      listBuilderBloc.add(TooglePlayMode());
    }

    List<TaleModel>? listTaleModels = await Navigator.of(context).pushNamed(
      SelectTalesToPlaylistScreen.routeName,
      arguments: listBuilderBloc.state.allTales,
    ) as List<TaleModel>?;

    listBuilderBloc.add(
      InitializeListBuilderWithTaleModels(listTaleModels),
    );
  }

  Future<void> _pickImage() async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    String? path = pickedImage?.path;
    if (path != null) {
      setState(() {
        _isImageValid = true;
        _playlistCover = File(path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListBuilderBloc>(
          create: (_) => ListBuilderBloc(),
        ),
        BlocProvider<AudioplayerBloc>(
          create: (_) => AudioplayerBloc()
            ..add(
              InitPlayer(),
            ),
        ),
      ],
      child: BackgroundPattern(
        patternColor: AppColors.seaNymph,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  primary: true,
                  toolbarHeight: 70,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: UndoButton(
                    undoChanges: _pop,
                  ),
                  title: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: 'Создание',
                        style: TextStyle(
                          fontFamily: 'TTNorms',
                          fontWeight: FontWeight.w700,
                          fontSize: 36,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    BlocBuilder<ListBuilderBloc, ListBuilderState>(
                      builder: (context, state) {
                        return Container(
                          margin: const EdgeInsets.only(
                            top: 20,
                            right: 15,
                          ),
                          child: TextButton(
                            onPressed: () {
                              _saveCollection(
                                allTales: context
                                    .read<ListBuilderBloc>()
                                    .state
                                    .allTales,
                              );
                            },
                            child: const Text(
                              'Готово',
                              style: TextStyle(
                                fontFamily: 'TTNorms',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
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
                            controller: _titleController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                            decoration: const InputDecoration(
                              hintText: 'Название...',
                              hintStyle: TextStyle(
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
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: AppColors.wildSand.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15),
                                border: _isImageValid
                                    ? null
                                    : Border.all(
                                        width: 2,
                                        color: Colors.red,
                                      ),
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
                                      child: _playlistCover != null
                                          ? Image.file(
                                              _playlistCover!,
                                              fit: BoxFit.fitWidth,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Center(
                                    child: SvgPicture.asset(
                                      AppIcons.chosePhoto,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextFormField(
                            style: const TextStyle(fontSize: 22),
                            decoration: const InputDecoration(
                              hintText: 'Введите описание...',
                              focusColor: Colors.red,
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: _descriptionController,
                            validator: (text) {
                              if (text != null && text.length > 400) {
                                return 'Слишком длинное название';
                              }
                              return null;
                            },
                            maxLines: 3,
                            minLines: 1,
                          ),
                          BlocBuilder<ListBuilderBloc, ListBuilderState>(
                            builder: (context, state) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      context
                                              .read<ListBuilderBloc>()
                                              .state
                                              .allTales
                                              .isNotEmpty
                                          ? TextButton(
                                              onPressed: () {
                                                _addTales(
                                                  context: context,
                                                );
                                              },
                                              child: const Text(
                                                'Изменить список',
                                                style: TextStyle(
                                                  fontFamily: 'TTNorms',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Colors.transparent,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor: Colors.black,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black,
                                                      offset: Offset(0, -5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      TextButton(
                                        onPressed: () =>
                                            FocusScope.of(context).unfocus(),
                                        child: const Text(
                                          'Готово',
                                          style: TextStyle(
                                            fontFamily: 'TTNorms',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 300,
                                    child: context
                                            .read<ListBuilderBloc>()
                                            .state
                                            .allTales
                                            .isNotEmpty
                                        ? _ListBuilder(
                                            scrollController: _scrollController,
                                          )
                                        : Center(
                                            child: TextButton(
                                              onPressed: () {
                                                _addTales(
                                                  context: context,
                                                );
                                              },
                                              child: const Text(
                                                'Добавить аудиофайл',
                                                style: TextStyle(
                                                  fontFamily: 'TTNorms',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Colors.transparent,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor: Colors.black,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black,
                                                      offset: Offset(0, -5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ListBuilder extends StatelessWidget {
  const _ListBuilder({
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  final ScrollController scrollController;

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

                return TaleListTileWithPopupMenu(
                    key: UniqueKey(),
                    isPlayMode: isPlayMode,
                    taleModel: taleModel,
                    onAddToPlaylist: () {},
                    onDelete: () {
                      listBuilderBloc.add(
                        DeleteTale(
                          taleModel,
                        ),
                      );
                      context.read<ListBuilderBloc>().add(
                            DeleteTale(
                              taleModel,
                            ),
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
                    });
              },
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
    final listBuilderBloc = BlocProvider.of<ListBuilderBloc>(context);
    final audioPlayerBloc = BlocProvider.of<AudioplayerBloc>(context);

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
              isNextButtonAvalible: false,
              tooglePlayMode: () {
                listBuilderBloc.add(
                  TooglePlayMode(
                    taleModel: state.taleModel,
                  ),
                );
              },
              onSliderChangeEnd: (value) {
                audioPlayerBloc.add(
                  Seek(
                    currentPlayTimeInSec: value,
                  ),
                );
              },
              onSliderChanged: () => {},
            ),
          );
        }
        return Container();
      },
    );
  }
}
