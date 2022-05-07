import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/list_builder/list_builder_bloc.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/screens/deleted_tales_screen/widgets/tale_list_tile_with_delete_button.dart';
import 'package:memory_box/utils/formatting.dart';
import 'package:memory_box/widgets/appBar/appBar_multirow_title.dart';
import 'package:memory_box/widgets/audioplayer/audio_player.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/tale_list_tiles/tale_list_tile_with_checkbox.dart';

class DeletedTalesScreen extends StatefulWidget {
  static const routeName = 'DeletedTalesScreen';

  const DeletedTalesScreen({Key? key}) : super(key: key);

  @override
  _DeletedTalesScreenState createState() => _DeletedTalesScreenState();
}

class _DeletedTalesScreenState extends State<DeletedTalesScreen> {
  List<TaleModel> _selectedTales = [];
  bool _isSelectMode = false;

  void _resumeTales({
    required List<TaleModel> taleModels,
    required BuildContext context,
  }) {
    List<TaleModel> updatedTaleModels = [
      ...context.read<ListBuilderBloc>().state.allTales
    ];

    for (final TaleModel taleModel in taleModels) {
      DatabaseService.instance.updateTale(
        taleID: taleModel.ID,
        isDeleted: false,
      );

      updatedTaleModels.remove(taleModel);
    }

    context.read<ListBuilderBloc>().add(
          InitializeListBuilderWithTaleModels(updatedTaleModels),
        );
  }

  void _toogleTaleSelectMode(TaleModel taleModel) {
    final bool isSelect = _selectedTales.contains(taleModel);

    setState(() {
      if (isSelect) {
        _selectedTales.remove(taleModel);
      } else {
        _selectedTales.add(taleModel);
      }
    });
  }

  void _undoSelectMode() {
    _selectedTales.clear();
    setState(() {
      _isSelectMode = false;
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
                    DatabaseService.instance.getAllDeletedTaleModels(),
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
      child: BackgroundPattern(
        patternColor: const Color.fromRGBO(103, 139, 210, 1),
        isShort: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _CustomAppBar(
            leadingOnPress: _isSelectMode
                ? null
                : () {
                    Scaffold.of(context).openDrawer();
                  },
            title: const AppBarMultirowTitle(
              title: 'Недавно \n удаленные',
            ),
            popupMenuButton: BlocBuilder<ListBuilderBloc, ListBuilderState>(
              builder: (context, state) {
                if (_isSelectMode) {
                  return _SelectPopUpMenuButton(
                    onToogleSelectMode: () {
                      setState(() {
                        _isSelectMode = true;
                      });
                    },
                    onDeleteSelected: () {
                      context.read<ListBuilderBloc>().add(
                            DeleteFewTales(_selectedTales),
                          );
                    },
                    onResumeSelected: () {
                      _resumeTales(
                        context: context,
                        taleModels: _selectedTales,
                      );
                    },
                  );
                }
                return _PopUpMenuButton(
                  onToogleSelectMode: () {
                    setState(() {
                      _isSelectMode = true;
                    });
                  },
                  onDeleteAll: () {
                    context.read<ListBuilderBloc>().add(
                          DeleteFewTales(state.allTales),
                        );
                  },
                  onResumeAll: () {
                    _resumeTales(
                      context: context,
                      taleModels: state.allTales,
                    );
                  },
                );
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Column(
              children: [
                if (_isSelectMode)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _undoSelectMode,
                        child: const Text(
                          'Отменить',
                          style: TextStyle(
                            fontFamily: 'TTNorms',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 100,
                    ),
                    child: _ListBuilder(
                      isSelectMode: _isSelectMode,
                      toogleTaleSelectMode: _toogleTaleSelectMode,
                      selectedTales: _selectedTales,
                    ),
                  ),
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
  _ListBuilder({
    required this.selectedTales,
    required this.isSelectMode,
    required this.toogleTaleSelectMode,
    Key? key,
  }) : super(key: key);

  final List<TaleModel> selectedTales;
  final bool isSelectMode;
  final Function(TaleModel) toogleTaleSelectMode;

  Map<String, List<TaleModel>> talesByDate = {};

  @override
  Widget build(BuildContext context) {
    final audioPlayerBloc = context.read<AudioplayerBloc>();

    return BlocConsumer<ListBuilderBloc, ListBuilderState>(
      listener: (context, state) {
        if (state is PlayTaleState) {
          audioPlayerBloc.add(
            Play(
              taleModel: state.currentPlayTaleModel!,
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
        talesByDate.clear();

        for (TaleModel taleModel
            in context.read<ListBuilderBloc>().state.allTales) {
          String date = convertDateTimeToString(
            date: taleModel.deleteStatus.deleteDate!,
            dayTimeFormattingType: DayTimeFormattingType.dayMonthYear,
          );

          if (talesByDate[date] != null) {
            talesByDate[date]?.add(taleModel);
          } else {
            talesByDate[date] = [taleModel];
          }
        }

        // Сортировка по датам
        talesByDate.keys.toList().sort((String preview, String next) {
          String x = preview.split('').reversed.join('');
          String y = next.split('').reversed.join('');

          return y.compareTo(x);
        });

        return Stack(
          children: [
            ListView.builder(
              itemCount: talesByDate.length + 1,
              itemBuilder: (context, index) {
                if (talesByDate.length == index) {
                  return const SizedBox(
                    height: 90,
                  );
                }

                List<Widget> _customColumn = [];

                _customColumn.add(
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    child: Text(
                      talesByDate.keys.elementAt(index),
                    ),
                  ),
                );

                talesByDate.values
                    .elementAt(index)
                    .forEach((TaleModel taleModel) {
                  bool isPlay = false;

                  if (listBuilderState.currentPlayTaleModel == taleModel &&
                      listBuilderState.isPlay) {
                    isPlay = true;
                  }

                  if (isSelectMode) {
                    _customColumn.add(
                      TaleListTileWithCheckBox(
                          key: UniqueKey(),
                          isPlay: isPlay,
                          isSelected: selectedTales.contains(
                            taleModel,
                          ),
                          taleModel: taleModel,
                          tooglePlayMode: () {
                            context.read<ListBuilderBloc>().add(
                                  TooglePlayMode(
                                    taleModel: taleModel,
                                  ),
                                );
                          },
                          toogleSelectMode: () {
                            toogleTaleSelectMode(taleModel);
                          }),
                    );
                  } else {
                    _customColumn.add(
                      TaleListTileWithDeleteButton(
                        key: UniqueKey(),
                        taleModel: taleModel,
                        isPlay: isPlay,
                        onDelete: () {
                          context.read<ListBuilderBloc>().add(
                                DeleteTale(taleModel),
                              );
                        },
                        tooglePlayMode: () {
                          context.read<ListBuilderBloc>().add(
                                TooglePlayMode(
                                  taleModel: taleModel,
                                ),
                              );
                        },
                      ),
                    );
                  }
                });

                return Column(
                  children: _customColumn,
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
    final listBuilderBloc = context.read<ListBuilderBloc>();
    final audioPlayerBloc = context.read<AudioplayerBloc>();

    return BlocConsumer<AudioplayerBloc, AudioplayerState>(
      listener: (context, state) {
        if (state.isTaleEnd) {
          listBuilderBloc.add(
            TooglePlayMode(),
          );
          audioPlayerBloc.add(
            AnnulAudioPlayer(),
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
              onSliderChanged: () => {},
            ),
          );
        }
        return Container();
      },
    );
  }
}

class _PopUpMenuButton extends StatelessWidget {
  const _PopUpMenuButton({
    required this.onToogleSelectMode,
    required this.onDeleteAll,
    required this.onResumeAll,
    Key? key,
  }) : super(key: key);

  final VoidCallback onToogleSelectMode;
  final VoidCallback onDeleteAll;
  final VoidCallback onResumeAll;

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
          onTap: onToogleSelectMode,
          child: Text(
            "Выбрать несколько",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: onDeleteAll,
          child: Text(
            "Удалить все",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: onResumeAll,
          child: Text(
            "Востановить все",
            style: _popupMenuTextStyle,
          ),
        ),
      ],
    );
  }
}

class _SelectPopUpMenuButton extends StatelessWidget {
  const _SelectPopUpMenuButton({
    required this.onToogleSelectMode,
    required this.onDeleteSelected,
    required this.onResumeSelected,
    Key? key,
  }) : super(key: key);

  final VoidCallback onToogleSelectMode;
  final VoidCallback onDeleteSelected;
  final VoidCallback onResumeSelected;

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
          onTap: onToogleSelectMode,
          child: Text(
            "Оменить",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: onDeleteSelected,
          child: Text(
            "Удалить выделенное",
            style: _popupMenuTextStyle,
          ),
        ),
        PopupMenuItem(
          onTap: onResumeSelected,
          child: Text(
            "Востановить выделенное",
            style: _popupMenuTextStyle,
          ),
        ),
      ],
    );
  }
}

class _CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  const _CustomAppBar({
    required this.leadingOnPress,
    required this.title,
    required this.popupMenuButton,
    Key? key,
  }) : super(key: key);

  final VoidCallback? leadingOnPress;
  final Widget title;
  final Widget? popupMenuButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      primary: true,
      toolbarHeight: 100,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.only(left: 6),
        child: leadingOnPress != null
            ? IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/Burger.svg',
                ),
                onPressed: leadingOnPress!,
              )
            : Container(),
      ),
      title: title,
      actions: [
        Container(
          margin: const EdgeInsets.only(
            right: 15,
          ),
          child: popupMenuButton,
        )
      ],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
