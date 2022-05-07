part of 'playlist_builder_bloc.dart';

class PlaylistBuilderState extends Equatable {
  final bool isInit;
  final List<PlaylistModel> allPlaylists;

  const PlaylistBuilderState({
    this.isInit = false,
    this.allPlaylists = const [],
  });

  PlaylistBuilderState copyWith({
    bool? isInit,
    bool? isSelectMode,
    List<PlaylistModel>? allPlaylists,
    List<PlaylistModel>? selectedPlaylists,
  }) {
    return PlaylistBuilderState(
      isInit: isInit ?? this.isInit,
      allPlaylists: allPlaylists ?? this.allPlaylists,
    );
  }

  @override
  List<Object?> get props => [
        isInit,
        allPlaylists,
      ];
}
