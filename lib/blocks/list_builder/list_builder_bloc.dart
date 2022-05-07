import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
part 'list_builder_event.dart';
part 'list_builder_state.dart';

class ListBuilderBloc extends Bloc<ListBuilderEvent, ListBuilderState> {
  ListBuilderBloc() : super(const ListBuilderState()) {
    on<InitializeListBuilderWithFutureRequest>((event, emit) async {
      List<TaleModel> allTales = await event.talesInitRequest;

      emit(
        state.copyWith(
          isInit: true,
          allTales: allTales,
        ),
      );
    });

    on<InitializeListBuilderWithTaleModels>((event, emit) async {
      emit(
        state.copyWith(
          isInit: true,
          allTales: event.initializationTales,
        ),
      );
    });

    on<DeleteTale>((event, emit) async {
      if (event.taleModel.deleteStatus.isDeleted) {
        DatabaseService.instance.finalDeleteTaleRecord(event.taleModel.ID);
      } else {
        DatabaseService.instance.updateTale(
          taleID: event.taleModel.ID,
          isDeleted: true,
        );
      }

      List<TaleModel> taleModels = [...state.allTales];
      taleModels.remove(event.taleModel);
      emit(
        state.copyWith(allTales: taleModels),
      );
    });

    on<DeleteFewTales>((event, emit) async {
      List<TaleModel> taleModels = [...state.allTales];

      for (final TaleModel taleModel in event.taleModels) {
        if (taleModel.deleteStatus.isDeleted) {
          DatabaseService.instance.finalDeleteTaleRecord(taleModel.ID);
        } else {
          DatabaseService.instance.updateTale(
            taleID: taleModel.ID,
            isDeleted: true,
          );
        }

        taleModels.remove(taleModel);
      }

      emit(
        state.copyWith(allTales: taleModels),
      );
    });

    on<UndoRenameTale>((event, emit) {
      emit(state.copyWith());
    });
    on<RenameTale>((event, emit) {
      DatabaseService.instance.updateTale(
        taleID: event.taleID,
        title: event.newTitle,
      );

      List<TaleModel>? updatedTaleList = state.allTales;

      int? renamedIndex = state.allTales.indexWhere(
        (element) => element.ID == event.taleID,
      );

      updatedTaleList[renamedIndex] =
          state.allTales[renamedIndex].copyWith(title: event.newTitle);

      emit(
        state.copyWith(allTales: updatedTaleList),
      );
    });

    on<TooglePlayMode>((event, emit) {
      if (state.isPlay && state.currentPlayTaleModel == event.taleModel ||
          event.taleModel == null) {
        emit(
          StopTaleState(
            isInit: state.isInit,
            isPlay: false,
            allTales: state.allTales,
            currentPlayTaleModel: state.currentPlayTaleModel,
            isPlayAllTalesMode: state.isPlayAllTalesMode,
          ),
        );
      } else {
        emit(
          PlayTaleState(
            isInit: state.isInit,
            isPlay: true,
            allTales: state.allTales,
            currentPlayTaleModel: event.taleModel,
            isPlayAllTalesMode: state.isPlayAllTalesMode,
          ),
        );
      }
    });

    on<TooglePlayAllMode>((event, emit) {
      emit(
        state.copyWith(
          isPlayAllTalesMode: !state.isPlayAllTalesMode,
        ),
      );
    });

    on<NextTale>((event, emit) {
      if (state.currentPlayTaleModel == null) return;
      int nextIndex = state.allTales
              .indexWhere((element) => element == state.currentPlayTaleModel) +
          1;

      if (nextIndex >= state.allTales.length) {
        nextIndex = 0;
      }

      add(
        TooglePlayMode(
          taleModel: state.allTales[nextIndex],
        ),
      );
    });
  }
}
