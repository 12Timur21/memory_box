import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:memory_box/models/playlist_model.dart';
import 'package:memory_box/models/tale_model.dart';

part 'playlist_builder_event.dart';
part 'playlist_builder_state.dart';

class PlaylistBuilderBloc
    extends Bloc<PlaylistBuilderEvent, PlaylistBuilderState> {
  PlaylistBuilderBloc() : super(const PlaylistBuilderState()) {
    on<InitializePlaylistBuilderWithFutureRequest>((event, emit) async {
      emit(
        PlaylistBuilderState(
          isInit: true,
          allPlaylists: await event.initializationPlaylistRequest,
        ),
      );
    });
    on<UpdateCurrentPlaylist>((event, emit) {
      List<PlaylistModel> allPlaylistModels = [...state.allPlaylists];

      int taleIndexInAllList = allPlaylistModels.indexWhere(
        (element) => element.ID == event.playlistModel.ID,
      );

      allPlaylistModels[taleIndexInAllList] = event.playlistModel;

      emit(
        state.copyWith(
          allPlaylists: allPlaylistModels,
        ),
      );
    });
    on<AddNewPlaylist>((event, emit) {
      emit(
        state.copyWith(
          allPlaylists: [...state.allPlaylists, event.playlistModel],
        ),
      );
    });
    on<DeleteFewPlaylists>((event, emit) {
      List<PlaylistModel> allPlaylistModels = [...state.allPlaylists];

      for (PlaylistModel playlistModel in event.playlistModels) {
        allPlaylistModels.removeWhere(
          (element) => element.ID == playlistModel.ID,
        );
      }

      emit(
        state.copyWith(
          allPlaylists: allPlaylistModels,
        ),
      );
    });
    on<AddTaleToFewPlaylists>((event, emit) {});

    // on<ToogleSelectPlaylist>((event, emit) {
    //   List<PlaylistModel> selectedPlaylistModels = [...state.selectedPlaylists];
    //   if (selectedPlaylistModels.contains(event.playlistModel)) {
    //     selectedPlaylistModels.remove(event.playlistModel);
    //   } else {
    //     selectedPlaylistModels.add(event.playlistModel);
    //   }
    //   emit(
    //     state.copyWith(
    //       selectedPlaylists: selectedPlaylistModels,
    //     ),
    //   );
    // });
    // on<ToogleSelectMode>((event, emit) {
    //   emit(
    //     state.copyWith(
    //       isSelectMode: !state.isSelectMode,
    //     ),
    //   );
    // });
  }
}
