part of 'audioplayer_bloc.dart';

class AudioplayerState extends Equatable {
  final TaleModel? taleModel;
  final Duration? currentPlayPosition;
  final bool isPlay;
  final bool isPlayerInit;
  final bool isTaleInit;
  final bool isTaleEnd;
  final String? errorText;

  const AudioplayerState({
    this.taleModel,
    this.currentPlayPosition,
    this.isPlay = false,
    this.isPlayerInit = false,
    this.isTaleInit = false,
    this.isTaleEnd = false,
    this.errorText,
  });

  AudioplayerState copyWith({
    TaleModel? newTaleModel,
    Duration? newPlayDuration,
    bool? isPlay,
    bool? isPlayerInit,
    bool? isTaleInit,
    bool? isTaleEnd,
    String? errorText,
  }) {
    return AudioplayerState(
      taleModel: newTaleModel ?? this.taleModel,
      currentPlayPosition: newPlayDuration ?? this.currentPlayPosition,
      isPlay: isPlay ?? this.isPlay,
      isPlayerInit: isPlayerInit ?? this.isPlayerInit,
      isTaleInit: isTaleInit ?? this.isTaleInit,
      isTaleEnd: isTaleEnd ?? this.isTaleEnd,
      errorText: errorText ?? this.errorText,
    );
  }

  @override
  List<Object?> get props => [
        taleModel,
        currentPlayPosition,
        isPlay,
        isPlayerInit,
        isTaleInit,
        isTaleEnd,
        errorText,
      ];
}
