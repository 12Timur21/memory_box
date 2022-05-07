import 'package:equatable/equatable.dart';
import 'package:memory_box/models/tale_model.dart';

class PlaylistModel extends Equatable {
  final String ID;
  final String title;
  final String? description;
  final String coverUrl;
  final DateTime creation_date;
  final List<TaleModel> taleModels;

  const PlaylistModel({
    required this.ID,
    required this.title,
    this.description,
    required this.coverUrl,
    required this.creation_date,
    this.taleModels = const [],
  });

  static Future<PlaylistModel> fromJson(Map<String, dynamic> json) async {
    //Конвертация References в TaleModel
    final taleReferences = json['taleReferences'] as List<dynamic>;
    List<TaleModel> taleModels = [];

    for (var element in taleReferences) {
      await element.get().then((value) {
        taleModels.add(
          TaleModel.fromJson(
            value.data(),
          ),
        );
      });
    }

    return PlaylistModel(
      ID: json['ID'],
      title: json['title'],
      description: json['description'],
      coverUrl: json['coverUrl'],
      creation_date: json['creation_date'].toDate(),
      taleModels: taleModels,
    );
  }

  PlaylistModel copyWith({
    final String? title,
    final String? description,
    final String? coverUrl,
    final List<TaleModel>? taleModels,
  }) {
    return PlaylistModel(
      ID: this.ID,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      creation_date: this.creation_date,
      taleModels: taleModels ?? this.taleModels,
    );
  }

  @override
  List<Object?> get props => [
        ID,
        title,
        description,
        coverUrl,
        creation_date,
        taleModels,
      ];
}
