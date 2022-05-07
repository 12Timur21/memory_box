import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/list_builder/list_builder_bloc.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/widgets/appBar/appBar_multirow_title.dart';
import 'package:memory_box/widgets/app_bar_with_buttons.dart';
import 'package:memory_box/widgets/audioplayer/audio_player.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/search.dart';
import 'package:memory_box/widgets/tale_list_tiles/tale_list_tile_with_popup_menu.dart';
import 'package:share_plus/share_plus.dart';

class SearchTalesScreen extends StatefulWidget {
  static const routeName = 'SearchTalesScreen';

  const SearchTalesScreen({Key? key}) : super(key: key);

  @override
  _SearchTalesScreenState createState() => _SearchTalesScreenState();
}

class _SearchTalesScreenState extends State<SearchTalesScreen> {
  final TextEditingController _searchFieldContoller = TextEditingController();
  bool _searchFieldHasFocus = false;
  String? _searchValue;

  void _onSearchValueChange({
    required String value,
    required BuildContext context,
  }) {
    if (value.endsWith(' ')) return;
    _searchValue = value;
    context.read<ListBuilderBloc>().add(
          InitializeListBuilderWithFutureRequest(
            talesInitRequest: DatabaseService.instance.searchTalesByTitle(
              title: _searchValue,
            ),
          ),
        );
  }

  void _onSearchFocusChange({
    required bool hasFocus,
    required BuildContext context,
  }) {
    setState(() {
      _searchFieldHasFocus = hasFocus;
    });

    if (hasFocus) {
      context.read<ListBuilderBloc>().add(
            InitializeListBuilderWithFutureRequest(
              talesInitRequest: DatabaseService.instance.searchTalesByTitle(
                title: _searchValue,
              ),
            ),
          );
    }
  }

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
        patternColor: const Color.fromRGBO(103, 139, 210, 1),
        isShort: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          appBar: AppBarWithButtons(
            leadingOnPress: () {
              Scaffold.of(context).openDrawer();
            },
            title: const AppBarMultirowTitle(
              title: 'Поиск',
              subtitile: 'Найди потеряшку',
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                BlocBuilder<ListBuilderBloc, ListBuilderState>(
                  builder: (context, state) {
                    return Stack(
                      children: [
                        Search(
                          searchFieldContoller: _searchFieldContoller,
                          onChange: (value) {
                            _onSearchValueChange(
                              value: value,
                              context: context,
                            );
                          },
                          onFocusChange: (isHasFocus) {
                            _onSearchFocusChange(
                              hasFocus: isHasFocus,
                              context: context,
                            );
                          },
                          onIconPress: () {
                            FocusScope.of(context).unfocus();

                            setState(() {
                              _searchFieldHasFocus = false;
                            });
                          },
                        ),
                        if (_searchFieldHasFocus)
                          Container(
                            margin: const EdgeInsets.only(
                              top: 80,
                            ),
                            height: 210,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 40,
                            ),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(246, 246, 246, 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 20,
                                  color: Color.fromRGBO(0, 0, 0, 0.18),
                                ),
                              ],
                            ),
                            child:
                                BlocBuilder<ListBuilderBloc, ListBuilderState>(
                              builder: (context, state) {
                                return ListView.builder(
                                  itemCount: state.allTales.length,
                                  itemBuilder: (context, index) {
                                    final TaleModel taleModel =
                                        state.allTales[index];
                                    return Container(
                                      alignment: Alignment.topLeft,
                                      child: TextButton(
                                        onPressed: () {
                                          context.read<ListBuilderBloc>().add(
                                                InitializeListBuilderWithTaleModels(
                                                  [taleModel],
                                                ),
                                              );

                                          FocusScope.of(context).unfocus();

                                          setState(() {
                                            _searchFieldHasFocus = false;
                                          });
                                        },
                                        child: Text(
                                          taleModel.title,
                                          style: const TextStyle(
                                            fontFamily: 'TTNorms',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 50,
                ),
                Expanded(
                  child:
                      _searchFieldHasFocus ? Container() : const _ListBuilder(),
                  // child: FutureBuilder<List<TaleModel>>(
                  //   future: DatabaseService.instance
                  //       .searchTalesByTitle(title: _searchValue),
                  //   builder: (
                  //     BuildContext context,
                  //     AsyncSnapshot<List<TaleModel>> snapshot,
                  //   ) {
                  //     if (snapshot.connectionState == ConnectionState.done) {
                  //       if (_searchHasFocus && snapshot.data?.length != 0) {

                  //           child: ListView.builder(
                  //             itemCount: snapshot.data?.length ?? 0,
                  //             itemBuilder: (context, index) {
                  //               print('list view builder');
                  //               TaleModel? taleModel = snapshot.data?[index];
                  //               if (taleModel != null) {
                  //                 return GestureDetector(
                  //                   onTap: () {
                  //                     _onSearchValueSelected(
                  //                       snapshot.data?[index].title ?? '',
                  //                     );
                  //                   },
                  //                   child: Padding(
                  //                     padding: EdgeInsets.only(
                  //                       top: index == 0 ? 0 : 25,
                  //                     ),
                  //                     child: Text(
                  //                       taleModel.title,
                  //                       style: const TextStyle(
                  //                         fontFamily: 'TTNorms',
                  //                         fontSize: 16,
                  //                         fontWeight: FontWeight.w400,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 );
                  //               }
                  //               return const SizedBox();
                  //             },
                  //           ),
                  //         );
                  //       } else {
                  //         return ListView.builder(
                  //           itemCount: snapshot.data?.length ?? 0,
                  //           itemBuilder: (context, index) {
                  //             TaleModel? taleModel = snapshot.data?[index];
                  //             if (taleModel != null) {
                  //               // return TaleListTileWithPopupMenu(
                  //               //   taleModel: taleModel,
                  //               // );
                  //             }
                  //             return const SizedBox();
                  //           },
                  //         );
                  //       }
                  //     }
                  //     return const Center(
                  //       child: CircularProgressIndicator(),
                  //     );
                  //   },
                  // ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListBuilder extends StatelessWidget {
  const _ListBuilder({
    // required this.scrollController,
    Key? key,
  }) : super(key: key);

  // final ScrollController scrollController;

  void _scrollDown() {
    // scrollController.animateTo(
    //   scrollController.position.maxScrollExtent,
    //   duration: const Duration(milliseconds: 500),
    //   curve: Curves.ease,
    // );
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
