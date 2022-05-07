part of 'list_builder_bloc.dart';

abstract class ListBuilderEvent {}

class InitializeListBuilderWithFutureRequest extends ListBuilderEvent {
  Future<List<TaleModel>> talesInitRequest;

  InitializeListBuilderWithFutureRequest({
    required this.talesInitRequest,
  });
}

class InitializeListBuilderWithTaleModels extends ListBuilderEvent {
  List<TaleModel>? initializationTales;

  InitializeListBuilderWithTaleModels(this.initializationTales);
}

class DeleteTale extends ListBuilderEvent {
  DeleteTale(this.taleModel);
  final TaleModel taleModel;
}

class DeleteFewTales extends ListBuilderEvent {
  DeleteFewTales(this.taleModels);
  final List<TaleModel> taleModels;
}

class UndoRenameTale extends ListBuilderEvent {}

class RenameTale extends ListBuilderEvent {
  RenameTale(
    this.taleID,
    this.newTitle,
  );

  final String taleID, newTitle;
}

class AddTaleToPlaylist extends ListBuilderEvent {}

class TooglePlayMode extends ListBuilderEvent {
  TooglePlayMode({this.taleModel});
  final TaleModel? taleModel;
}

class TooglePlayAllMode extends ListBuilderEvent {
  TooglePlayAllMode();
}

class NextTale extends ListBuilderEvent {}
