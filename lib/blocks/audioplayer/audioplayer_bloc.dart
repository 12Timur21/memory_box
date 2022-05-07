import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/services/soundPlayer.dart';

part 'audioplayer_event.dart';
part 'audioplayer_state.dart';

class AudioplayerBloc extends Bloc<AudioplayerEvent, AudioplayerState> {
  final SoundPlayer _soundPlayer = SoundPlayer();
  StreamSubscription? _soundNotifyerController;

  AudioplayerBloc() : super(const AudioplayerState()) {
    on<InitPlayer>((event, emit) async {
      bool _isPlayerInit = await _soundPlayer.initPlayer();

      if (_isPlayerInit) {
        emit(
          state.copyWith(
            isPlayerInit: true,
          ),
        );

        //Каждые n секунд обновляем позицию Duration и position сказки
        _soundNotifyerController =
            _soundPlayer.soundDurationStream?.listen((e) {
          log('${e.position.inMilliseconds} - ${e.duration.inMilliseconds}}');
          add(
            UpdateAudioPlayerPosition(
              currentPlayPosition: Duration(
                milliseconds: e.position.inMilliseconds,
              ),
              taleDuration: e.duration,
            ),
          );
        });
      } else {
        emit(
          state.copyWith(errorText: 'Не удалось провести инициализацию'),
        );
      }
    });
    on<TooglePositionNotifyer>((event, emit) async {
      if (_soundNotifyerController?.isPaused != null) {
        if (_soundNotifyerController!.isPaused) {
          _soundNotifyerController?.resume();
        } else {
          _soundNotifyerController?.pause();
        }
      }
    });
    on<InitTale>((event, emit) async {
      final Completer<void> whenFinished = Completer<void>();

      Duration? taleDuration = await _soundPlayer.initTale(
          taleModel: event.taleModel,
          isAutoPlay: event.isAutoPlay,
          whenFinished: () async {
            whenFinished.complete();
          });

      emit(
        state.copyWith(
          isPlay: event.isAutoPlay,
          isTaleInit: true,
          isTaleEnd: false,
          newTaleModel: event.taleModel.copyWith(
            duration: taleDuration,
          ),
        ),
      );

      await whenFinished.future.then((_) {
        emit(
          state.copyWith(
            isTaleEnd: true,
            newPlayDuration: Duration.zero,
            isPlay: false,
          ),
        );
      });
    });
    on<Play>((event, emit) async {
      //Если модель уже была инициализирована, то плеер продолжит с прошлого места
      if (state.isTaleInit && state.taleModel?.ID == event.taleModel.ID) {
        if (_soundPlayer.isSoundPlay) {
          return;
        }
        await _soundPlayer.resumePlayer();
        emit(
          state.copyWith(
            isPlay: true,
          ),
        );
      } else {
        add(
          InitTale(
            taleModel: event.taleModel,
            isAutoPlay: event.isAutoPlay,
          ),
        );
      }
    });
    on<Pause>((event, emit) async {
      await _soundPlayer.pausePlayer();

      emit(
        state.copyWith(
          isPlay: false,
        ),
      );
    });
    on<Seek>((event, emit) {
      int currentPlayTimeInSec = event.currentPlayTimeInSec.toInt();
      _soundPlayer.seek(
        currentPlayTime: Duration(seconds: currentPlayTimeInSec),
      );
      emit(
        state.copyWith(
          newPlayDuration: Duration(
            seconds: currentPlayTimeInSec,
          ),
        ),
      );
    });
    on<AnnulAudioPlayer>((event, emit) {
      add(
        InitTale(
          taleModel: state.taleModel!,
          isAutoPlay: false,
        ),
      );
    });
    on<UpdateAudioPlayerPosition>((event, emit) {
      emit(
        state.copyWith(
          newPlayDuration: event.currentPlayPosition,
          newTaleModel: state.taleModel?.copyWith(
            duration: event.taleDuration,
          ),
        ),
      );
    });
    on<MoveBackward15Sec>((event, emit) async {
      Duration newPlayDuration = await _soundPlayer.moveBackward15Sec(
        currentPlayDuration: state.currentPlayPosition!,
      );

      emit(
        state.copyWith(
          newPlayDuration: newPlayDuration,
        ),
      );
    });
    on<MoveForward15Sec>((event, emit) async {
      Duration newPlayDuration = await _soundPlayer.moveForward15Sec(
        currentPlayDuration: state.currentPlayPosition!,
        taleDuration: state.taleModel!.duration,
      );

      emit(
        state.copyWith(
          newPlayDuration: newPlayDuration,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _soundNotifyerController?.cancel();
    _soundPlayer.dispose();
    return super.close();
  }
}
