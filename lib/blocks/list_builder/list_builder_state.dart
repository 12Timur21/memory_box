part of 'list_builder_bloc.dart';

class ListBuilderState extends Equatable {
  final bool isInit;
  final bool isPlay;
  final bool isPlayAllTalesMode;
  final List<TaleModel> allTales;
  final TaleModel? currentPlayTaleModel;

  const ListBuilderState({
    this.isInit = false,
    this.isPlay = false,
    this.isPlayAllTalesMode = false,
    this.allTales = const [],
    this.currentPlayTaleModel,
  });

  ListBuilderState copyWith({
    bool? isInit,
    bool? isPlay,
    bool? isPlayAllTalesMode,
    List<TaleModel>? allTales,
    TaleModel? currentPlayTaleModel,
  }) {
    return ListBuilderState(
      isInit: isInit ?? this.isInit,
      isPlay: isPlay ?? this.isPlay,
      isPlayAllTalesMode: isPlayAllTalesMode ?? this.isPlayAllTalesMode,
      allTales: allTales ?? this.allTales,
      currentPlayTaleModel: currentPlayTaleModel ?? this.currentPlayTaleModel,
    );
  }

  @override
  List<Object?> get props => [
        isInit,
        isPlay,
        isPlayAllTalesMode,
        allTales,
        currentPlayTaleModel,
      ];
}

class PlayTaleState extends ListBuilderState {
  const PlayTaleState({
    required bool isInit,
    required bool isPlay,
    required bool isPlayAllTalesMode,
    required List<TaleModel> allTales,
    required TaleModel? currentPlayTaleModel,
  }) : super(
          isInit: isInit,
          isPlay: isPlay,
          isPlayAllTalesMode: isPlayAllTalesMode,
          allTales: allTales,
          currentPlayTaleModel: currentPlayTaleModel,
        );
}

class StopTaleState extends ListBuilderState {
  const StopTaleState({
    required bool isInit,
    required bool isPlay,
    required bool isPlayAllTalesMode,
    required List<TaleModel> allTales,
    required TaleModel? currentPlayTaleModel,
  }) : super(
          isInit: isInit,
          isPlay: isPlay,
          isPlayAllTalesMode: isPlayAllTalesMode,
          allTales: allTales,
          currentPlayTaleModel: currentPlayTaleModel,
        );
}
