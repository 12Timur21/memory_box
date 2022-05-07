import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaleDeleteStatus extends Equatable {
  final bool isDeleted;
  final DateTime? deleteDate;

  const TaleDeleteStatus({
    required this.isDeleted,
    this.deleteDate,
  });

  @override
  List<Object?> get props => [isDeleted, deleteDate];
}

class TaleModel extends Equatable {
  final String ID;
  final String title;
  final String url;
  final Duration duration;
  final TaleDeleteStatus deleteStatus;

  const TaleModel({
    required this.ID,
    required this.duration,
    required this.title,
    required this.url,
    this.deleteStatus = const TaleDeleteStatus(
      isDeleted: false,
    ),
  });

  TaleModel copyWith({
    String? ID,
    String? title,
    String? url,
    Duration? duration,
    TaleDeleteStatus? deleteStatus,
  }) {
    return TaleModel(
      ID: ID ?? this.ID,
      title: title ?? this.title,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      deleteStatus: deleteStatus ?? this.deleteStatus,
    );
  }

  @override
  List<Object?> get props => [ID, title, url, deleteStatus];

  factory TaleModel.fromJson(Map<String, dynamic> json) {
    Timestamp? timeStamp = (json['isDeleted']['deleteDate'] as Timestamp?);

    return TaleModel(
      title: json['title'],
      ID: json['taleID'],
      url: json['taleUrl'],
      duration: Duration(
        milliseconds: json['durationInMS'],
      ),
      deleteStatus: TaleDeleteStatus(
        isDeleted: json['isDeleted']['status'],
        deleteDate: timeStamp == null
            ? null
            : DateTime.fromMicrosecondsSinceEpoch(
                timeStamp.microsecondsSinceEpoch,
              ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'taleID': ID,
      'title': title,
      'durationInMS': duration.inMilliseconds,
      'isDeleted': {
        'status': deleteStatus.isDeleted,
        'deleteDate': deleteStatus.deleteDate,
      },
      'taleUrl': url,
      'searchKey': title.toLowerCase(),
    };
  }
}
