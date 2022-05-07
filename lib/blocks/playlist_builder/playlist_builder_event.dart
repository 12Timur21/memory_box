part of 'playlist_builder_bloc.dart';

abstract class PlaylistBuilderEvent extends Equatable {
  const PlaylistBuilderEvent();

  @override
  List<Object> get props => [];
}

class InitializePlaylistBuilderWithFutureRequest extends PlaylistBuilderEvent {
  const InitializePlaylistBuilderWithFutureRequest({
    required this.initializationPlaylistRequest,
  });
  final Future<List<PlaylistModel>> initializationPlaylistRequest;
  @override
  List<Object> get props => [initializationPlaylistRequest];
}

class AddNewPlaylist extends PlaylistBuilderEvent {
  const AddNewPlaylist({
    required this.playlistModel,
  });
  final PlaylistModel playlistModel;

  @override
  List<Object> get props => [playlistModel];
}

class ToogleSelectPlaylist extends PlaylistBuilderEvent {
  const ToogleSelectPlaylist({
    required this.playlistModel,
  });
  final PlaylistModel playlistModel;

  @override
  List<Object> get props => [playlistModel];
}

class DeleteFewPlaylists extends PlaylistBuilderEvent {
  const DeleteFewPlaylists({
    required this.playlistModels,
  });
  final List<PlaylistModel> playlistModels;
  @override
  List<Object> get props => [playlistModels];
}

class AddTaleToFewPlaylists extends PlaylistBuilderEvent {
  const AddTaleToFewPlaylists({
    required this.taleModel,
    required this.playlistModels,
  });
  final TaleModel taleModel;
  final List<PlaylistModel> playlistModels;

  @override
  List<Object> get props => [taleModel, playlistModels];
}

class UpdateCurrentPlaylist extends PlaylistBuilderEvent {
  const UpdateCurrentPlaylist(this.playlistModel);
  final PlaylistModel playlistModel;
}

class ToogleSelectMode extends PlaylistBuilderEvent {}
