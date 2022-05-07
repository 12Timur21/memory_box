import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/bottom_navigation_index_control/bottom_navigation_index_control_cubit.dart';
import 'package:memory_box/blocks/list_builder/list_builder_bloc.dart';
import 'package:memory_box/models/playlist_model.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/screens/all_tales_screen/all_tales_screen.dart';
import 'package:memory_box/screens/playlist_screen/detailed_playlist_screen.dart';
import 'package:memory_box/screens/playlist_screen/playlist_screen.dart';
import 'package:memory_box/utils/formatting.dart';
import 'package:memory_box/widgets/audioplayer/audio_player.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/tale_list_tiles/tale_list_tile_with_popup_menu.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'HomeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PlaylistModel> _playlistModels = [];

  @override
  void initState() {
    asyncInit();
    super.initState();
  }

  Future<void> asyncInit() async {
    _playlistModels = await DatabaseService.instance.getThreePlaylistModels();
    setState(() {});
  }

  void _openPlaylist({
    required PlaylistModel playlistModel,
    required BuildContext context,
    required int index,
  }) async {
    PlaylistModel? updatedPlaylistModel = await Navigator.of(context).pushNamed(
      DetailedPlaylistScreen.routeName,
      arguments: playlistModel,
    ) as PlaylistModel?;

    if (updatedPlaylistModel != null) {
      _playlistModels[index] = updatedPlaylistModel;
    } else {
      //!!
      // playlistBuilderBloc.add(
      //   DeleteFewPlaylists(
      //     playlistModels: [playlistModel],
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListBuilderBloc>(
          create: (_) => ListBuilderBloc()
            ..add(
              InitializeListBuilderWithFutureRequest(
                talesInitRequest:
                    DatabaseService.instance.getAllNotDeletedTaleModels(),
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
      child: Builder(builder: (context) {
        return BackgroundPattern(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            appBar: AppBar(
              primary: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.only(left: 6),
                child: IconButton(
                  icon: SvgPicture.asset(
                    AppIcons.burger,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Подборки',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'TTNorms',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AllTalesScreen.routeName,
                                  );

                                  context
                                      .read<BottomNavigationIndexControlCubit>()
                                      .changeIndex(3);
                                },
                                child: const Text(
                                  'Открыть все',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'TTNorms',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          child: SizedBox(
                            height: 240,
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        PlaylistScreen.routeName,
                                      );
                                      context
                                          .read<
                                              BottomNavigationIndexControlCubit>()
                                          .changeIndex(1);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        right: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.seaNymph.withOpacity(0.9),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                      ),
                                      child: _playlistModels.length >= 1
                                          ? _PlaylistCover(
                                              onTap: () => _openPlaylist(
                                                playlistModel:
                                                    _playlistModels[0],
                                                context: context,
                                                index: 0,
                                              ),
                                              playlistModel: _playlistModels[0],
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 30,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Text(
                                                    'Здесь будет твой набор сказок',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontFamily: 'TTNorms',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    'Добавить',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'TTNorms',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.white,
                                                          offset: Offset(0, -5),
                                                        )
                                                      ],
                                                      color: Colors.transparent,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: _playlistModels.length >= 2
                                            ? _PlaylistCover(
                                                playlistModel:
                                                    _playlistModels[1],
                                                onTap: () => _openPlaylist(
                                                  playlistModel:
                                                      _playlistModels[1],
                                                  context: context,
                                                  index: 1,
                                                ),
                                              )
                                            : Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.tacao
                                                      .withOpacity(0.9),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(15),
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'Тут',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Expanded(
                                        child: _playlistModels.length >= 3
                                            ? _PlaylistCover(
                                                playlistModel:
                                                    _playlistModels[2],
                                                onTap: () => _openPlaylist(
                                                  playlistModel:
                                                      _playlistModels[2],
                                                  context: context,
                                                  index: 2,
                                                ),
                                              )
                                            : Container(
                                                margin: const EdgeInsets.only(
                                                  top: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.danube
                                                      .withOpacity(0.9),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(15),
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'Тут',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: BottomSheet(
                            onClosing: () {},
                            enableDrag: false,
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height * 0.38,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.38,
                            ),
                            builder: (context) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.wildSand,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 4),
                                      blurRadius: 24,
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Аудиозаписи',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'TTNorms',
                                            fontSize: 24,
                                            letterSpacing: 0.4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              AllTalesScreen.routeName,
                                            );
                                            context
                                                .read<
                                                    BottomNavigationIndexControlCubit>()
                                                .changeIndex(3);
                                          },
                                          child: const Text(
                                            'Открыть все',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'TTNorms',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Stack(
                                        children: const [
                                          _ListBuilder(),
                                          _AudioPlayer(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _ListBuilder extends StatefulWidget {
  const _ListBuilder({
    this.scrollController,
    Key? key,
  }) : super(key: key);

  final ScrollController? scrollController;

  @override
  __ListBuilderState createState() => __ListBuilderState();
}

class __ListBuilderState extends State<_ListBuilder> {
  void _scrollDown() {
    widget.scrollController?.animateTo(
      widget.scrollController!.position.maxScrollExtent,
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

class _PlaylistCover extends StatefulWidget {
  const _PlaylistCover({
    required this.playlistModel,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final PlaylistModel playlistModel;
  final VoidCallback onTap;
  @override
  __PlaylistCoverState createState() => __PlaylistCoverState();
}

class __PlaylistCoverState extends State<_PlaylistCover> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.network(
                  widget.playlistModel.coverUrl,
                  height: 240,
                  fit: BoxFit.fill,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withOpacity(0),
                        AppColors.gray,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 20,
                          left: 15,
                          right: 15,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                widget.playlistModel.title,
                                style: const TextStyle(
                                  fontFamily: 'TTNorms',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.playlistModel.taleModels.length} аудио',
                                  style: const TextStyle(
                                    fontFamily: 'TTNorms',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  '${convertDurationToString(
                                    duration: widget.playlistModel.taleModels
                                        .fold<Duration>(
                                      Duration.zero,
                                      (Duration previousValue, element) =>
                                          previousValue + element.duration,
                                    ),
                                    formattingType:
                                        TimeFormattingType.hourMinute,
                                  )} ${widget.playlistModel.taleModels.fold<Duration>(
                                        Duration.zero,
                                        (Duration previousValue, element) =>
                                            previousValue + element.duration,
                                      ).inHours > 0 ? "часа" : "минут"}',
                                  style: const TextStyle(
                                    fontFamily: 'TTNorms',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
