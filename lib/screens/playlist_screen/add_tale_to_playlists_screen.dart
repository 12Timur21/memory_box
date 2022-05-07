import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/blocks/playlist_builder/playlist_builder_bloc.dart';
import 'package:memory_box/models/playlist_model.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/screens/playlist_screen/create_playlist_screen.dart';
import 'package:memory_box/screens/playlist_screen/widgets/tiles/select_playtlist_tile.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';

class AddTaleToPlaylists extends StatefulWidget {
  static const routeName = 'AddTaleToPlaylists';

  const AddTaleToPlaylists({
    required this.taleModels,
    Key? key,
  }) : super(key: key);

  final List<TaleModel> taleModels;

  @override
  _AddTaleToPlaylistsState createState() => _AddTaleToPlaylistsState();
}

class _AddTaleToPlaylistsState extends State<AddTaleToPlaylists> {
  final List<PlaylistModel> _selectedPlaylistModels = [];

  Future<void> _createNewPlaylist({
    required BuildContext context,
  }) async {
    PlaylistModel? _newPlaylistModel = await Navigator.of(context).pushNamed(
      CreatePlaylistScreen.routeName,
    ) as PlaylistModel?;

    if (_newPlaylistModel != null) {
      context.read<PlaylistBuilderBloc>().add(
            AddNewPlaylist(
              playlistModel: _newPlaylistModel,
            ),
          );
    }
  }

  void _addTalesToPlaylist() async {
    await DatabaseService.instance.addTalesToFewPlaylist(
      taleModels: [...widget.taleModels],
      playlistModels: _selectedPlaylistModels,
    );

    Navigator.of(context).pop();
  }

  void _toogleSelectMode(PlaylistModel playlistModel) {
    final bool isHasAlreadySelected =
        _selectedPlaylistModels.contains(playlistModel);

    setState(() {
      if (isHasAlreadySelected) {
        _selectedPlaylistModels.remove(playlistModel);
      } else {
        _selectedPlaylistModels.add(playlistModel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlaylistBuilderBloc()
        ..add(
          InitializePlaylistBuilderWithFutureRequest(
            initializationPlaylistRequest:
                DatabaseService.instance.getAllPlayList(),
          ),
        ),
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
                leading: Container(
                  margin: const EdgeInsets.only(left: 6),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/Plus.svg',
                    ),
                    onPressed: () {
                      _createNewPlaylist(
                        context: context,
                      );
                    },
                  ),
                ),
                title: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: 'Подборки',
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
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                      top: 15,
                      right: 15,
                    ),
                    child: TextButton(
                      onPressed: _addTalesToPlaylist,
                      child: const Text(
                        'Добавить',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'TTNorms',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                elevation: 0,
              ),
              body: Container(
                margin: const EdgeInsets.only(
                  top: 30,
                ),
                child: BlocConsumer<PlaylistBuilderBloc, PlaylistBuilderState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (!state.isInit) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return GridView.count(
                      primary: true,
                      crossAxisCount: 2,
                      childAspectRatio: 190 / 240,
                      children: List.generate(
                        state.allPlaylists.length,
                        (index) {
                          PlaylistModel playlistModel =
                              state.allPlaylists[index];
                          bool isSelected =
                              _selectedPlaylistModels.contains(playlistModel)
                                  ? true
                                  : false;
                          return Container(
                            margin: index % 2 == 0
                                ? const EdgeInsets.only(
                                    top: 20,
                                    left: 15,
                                    right: 8,
                                  )
                                : const EdgeInsets.only(
                                    top: 20,
                                    right: 15,
                                    left: 8,
                                  ),
                            child: SelectPlaylistTile(
                              key: UniqueKey(),
                              isSelected: isSelected,
                              onSelect: () {
                                _toogleSelectMode(playlistModel);
                              },
                              playlistModel: playlistModel,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
