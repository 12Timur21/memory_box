import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/list_builder/list_builder_bloc.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/widgets/audioplayer/audio_player.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/search.dart';
import 'package:memory_box/widgets/tale_list_tiles/tale_list_tile_with_checkbox.dart';
import 'package:memory_box/widgets/undoButton.dart';

class SelectTalesToPlaylistScreen extends StatefulWidget {
  static const routeName = 'SelectPlaylistTales';

  const SelectTalesToPlaylistScreen({
    this.selectedTales,
    Key? key,
  }) : super(key: key);

  final List<TaleModel>? selectedTales;

  @override
  _SelectTalesToPlaylistScreenState createState() =>
      _SelectTalesToPlaylistScreenState();
}

class _SelectTalesToPlaylistScreenState
    extends State<SelectTalesToPlaylistScreen> {
  String? _searchValue;
  final TextEditingController _searchFieldContoller = TextEditingController();
  late final List<TaleModel> _selectedTales;

  @override
  void initState() {
    _selectedTales = [...widget.selectedTales ?? const []];
    super.initState();
  }

  void _onSearchValueChange({
    required BuildContext context,
    required String value,
  }) {
    if (value.endsWith(' ')) return;

    _searchValue = value;

    context.read<ListBuilderBloc>().add(
          InitializeListBuilderWithFutureRequest(
            talesInitRequest: DatabaseService.instance
                .searchTalesByTitle(title: _searchValue),
          ),
        );
  }

  Future<void> _onRefresh({
    required BuildContext context,
  }) {
    context.read<ListBuilderBloc>().add(
          InitializeListBuilderWithFutureRequest(
            talesInitRequest: DatabaseService.instance
                .searchTalesByTitle(title: _searchValue),
          ),
        );
    return Future.value();
  }

  void _undoChanges() {
    Navigator.of(context).pop(
      widget.selectedTales,
    );
  }

  void _saveChanges() {
    Navigator.of(context).pop(
      _selectedTales,
    );
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
                  undoChanges: _undoChanges,
                ),
                title: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: 'Выбрать',
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
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                      right: 15,
                    ),
                    child: TextButton(
                      onPressed: _saveChanges,
                      child: const Text(
                        'Добавить',
                        style: TextStyle(
                          fontFamily: 'TTNorms',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
                elevation: 0,
              ),
              body: Container(
                margin: const EdgeInsets.only(
                  top: 25,
                  left: 15,
                  right: 15,
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Search(
                      searchFieldContoller: _searchFieldContoller,
                      onChange: (value) => _onSearchValueChange(
                        context: context,
                        value: value,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    _ListBuilder(
                      selectedTales: _selectedTales,
                      onToogleSelect: (TaleModel taleModel) {
                        _toogleTaleSelectMode(taleModel);
                      },
                      onRefresh: () => _onRefresh(
                        context: context,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ListBuilder extends StatelessWidget {
  _ListBuilder({
    required this.selectedTales,
    required this.onRefresh,
    required this.onToogleSelect,
    // required this.scrollController,
    Key? key,
  }) : super(key: key);

  final List<TaleModel> selectedTales;
  final Future<void> Function() onRefresh;
  final Function(TaleModel) onToogleSelect;

  final ScrollController _scrollController = ScrollController();

  void _scrollDown({
    required int index,
  }) {
    double taleHeight = 72;

    _scrollController.animateTo(
      taleHeight * index,
      duration: const Duration(seconds: 1),
      curve: Curves.easeIn,
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
        return Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: onRefresh,
                child: listBuilderState.isInit
                    ? ListView.builder(
                        itemCount: listBuilderState.allTales.length + 1,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          final int talesLength =
                              listBuilderState.allTales.length;

                          if (talesLength == index) {
                            return const SizedBox(
                              height: 90,
                            );
                          }
                          final TaleModel taleModel =
                              listBuilderState.allTales[index];

                          bool isPlay = false;

                          if (listBuilderState.currentPlayTaleModel ==
                                  taleModel &&
                              listBuilderState.isPlay) {
                            isPlay = true;
                          }

                          return TaleListTileWithCheckBox(
                              key: UniqueKey(),
                              isPlay: isPlay,
                              isSelected: selectedTales.contains(
                                taleModel,
                              ),
                              taleModel: taleModel,
                              tooglePlayMode: () {
                                _scrollDown(
                                  index: index,
                                );
                                listBuilderBloc.add(
                                  TooglePlayMode(
                                    taleModel: taleModel,
                                  ),
                                );
                              },
                              toogleSelectMode: () {
                                onToogleSelect(taleModel);
                              });
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
              const _AudioPlayer(),
            ],
          ),
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
          audioPlayerBloc.add(
            AnnulAudioPlayer(),
          );

          listBuilderBloc.add(
            TooglePlayMode(
              taleModel: state.taleModel,
            ),
          );
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
                  Seek(currentPlayTimeInSec: value),
                );
              },
              onSliderChanged: () {},
            ),
          );
        }
        return Container();
      },
    );
  }
}
