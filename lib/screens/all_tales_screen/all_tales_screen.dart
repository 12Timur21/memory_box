import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/list_builder/list_builder_bloc.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/screens/playlist_screen/add_tale_to_playlists_screen.dart';
import 'package:memory_box/utils/formatting.dart';
import 'package:memory_box/widgets/app_bar_with_buttons.dart';
import 'package:memory_box/widgets/audioplayer/audio_player.dart';
import 'package:memory_box/widgets/tale_list_tiles/tale_list_tile_with_popup_menu.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:share_plus/share_plus.dart';

class AllTalesScreen extends StatefulWidget {
  static const routeName = 'AllTalesScreen';
  const AllTalesScreen({Key? key}) : super(key: key);

  @override
  _AllTalesScreenState createState() => _AllTalesScreenState();
}

class _AllTalesScreenState extends State<AllTalesScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ListBuilderBloc()
            ..add(
              InitializeListBuilderWithFutureRequest(
                talesInitRequest:
                    DatabaseService.instance.getAllNotDeletedTaleModels(),
              ),
            ),
        ),
        BlocProvider(
          create: (context) => AudioplayerBloc()
            ..add(
              InitPlayer(),
            ),
        ),
      ],
      child: BackgroundPattern(
        patternColor: AppColors.lightBlue,
        isShort: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBarWithButtons(
            leadingOnPress: () {
              Scaffold.of(context).openDrawer();
            },
            title: Container(
              margin: const EdgeInsets.only(top: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Аудиозаписи',
                  style: TextStyle(
                    fontFamily: 'TTNorms',
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                    letterSpacing: 0.5,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '\n Все в одном месте',
                      style: TextStyle(
                        fontFamily: 'TTNorms',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: BlocConsumer<ListBuilderBloc, ListBuilderState>(
            listener: (context, state) {
              if (state is PlayTaleState) {
                final TaleModel taleModel = state.currentPlayTaleModel!;
                context.read<AudioplayerBloc>().add(
                      Play(
                        taleModel: taleModel,
                        isAutoPlay: true,
                      ),
                    );
              }

              if (state is StopTaleState) {
                context.read<AudioplayerBloc>().add(
                      Pause(),
                    );
              }
            },
            builder: (context, listBuilderState) {
              int _durationSumInMS = 0;
              for (final TaleModel taleModel in listBuilderState.allTales) {
                _durationSumInMS += taleModel.duration.inMilliseconds;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${listBuilderState.allTales.length} аудио',
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${convertDurationToString(
                                duration: Duration(
                                  milliseconds: _durationSumInMS,
                                ),
                                formattingType: TimeFormattingType.hourMinute,
                              )} часов',
                              style: Theme.of(context).textTheme.headline1,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.read<ListBuilderBloc>().add(
                                TooglePlayAllMode(),
                              ),
                          child: Container(
                            width: 222,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.wildSand.withOpacity(
                                listBuilderState.isPlayAllTalesMode ? 0.2 : 0.5,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 168,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.wildSand,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.play,
                                        width: 50,
                                      ),
                                      const Text('Запустить все'),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child: SvgPicture.asset(
                                    AppIcons.repeat,
                                    color: AppColors.wildSand.withOpacity(
                                      listBuilderState.isPlayAllTalesMode
                                          ? 1
                                          : 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          RefreshIndicator(
                            onRefresh: () {
                              context.read<ListBuilderBloc>().add(
                                    InitializeListBuilderWithFutureRequest(
                                      talesInitRequest: DatabaseService.instance
                                          .getAllNotDeletedTaleModels(),
                                    ),
                                  );
                              return Future.value();
                            },
                            child: listBuilderState.isInit
                                ? ListView.builder(
                                    itemCount: listBuilderState.allTales.length,
                                    itemBuilder: (context, index) {
                                      TaleModel taleModel =
                                          listBuilderState.allTales[index];
                                      bool isPlayMode = false;

                                      if (listBuilderState
                                                  .currentPlayTaleModel ==
                                              taleModel &&
                                          listBuilderState.isPlay) {
                                        isPlayMode = true;
                                      }

                                      return TaleListTileWithPopupMenu(
                                        key: UniqueKey(),
                                        isPlayMode: isPlayMode,
                                        taleModel: taleModel,
                                        onAddToPlaylist: () {
                                          Navigator.of(context).pushNamed(
                                            AddTaleToPlaylists.routeName,
                                            arguments: [taleModel],
                                          );
                                        },
                                        onDelete: () =>
                                            context.read<ListBuilderBloc>().add(
                                                  DeleteTale(taleModel),
                                                ),
                                        onRename: (String newTitle) =>
                                            context.read<ListBuilderBloc>().add(
                                                  RenameTale(
                                                    taleModel.ID,
                                                    newTitle,
                                                  ),
                                                ),
                                        onShare: () =>
                                            Share.share(taleModel.url),
                                        onUndoRenaming: () =>
                                            context.read<ListBuilderBloc>().add(
                                                  UndoRenameTale(),
                                                ),
                                        tooglePlayMode: () =>
                                            context.read<ListBuilderBloc>().add(
                                                  TooglePlayMode(
                                                    taleModel: taleModel,
                                                  ),
                                                ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                          const _AudioPlayer(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AudioPlayer extends StatelessWidget {
  const _AudioPlayer({
    Key? key,
  }) : super(key: key);

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
                isNextButtonAvalible: true,
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
                next: () {
                  listBuilderBloc.add(
                    NextTale(),
                  );
                },
                onSliderChanged: () => {}),
          );
        }
        return Container();
      },
    );
  }
}
