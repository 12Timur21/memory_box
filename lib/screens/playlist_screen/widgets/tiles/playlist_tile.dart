import 'package:flutter/material.dart';
import 'package:memory_box/models/playlist_model.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/utils/formatting.dart';

class PlaylistTile extends StatefulWidget {
  const PlaylistTile({
    required this.playlistModel,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final PlaylistModel playlistModel;
  final VoidCallback onTap;

  @override
  _PlaylistTileState createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
  bool isSelect = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        height: 240,
        width: 190,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    widget.playlistModel.coverUrl,
                    height: 240,
                    fit: BoxFit.fill,
                  ),
                  // CachedNetworkImage(
                  //   imageUrl: widget.playlistModel.coverUrl,
                  //   key: UniqueKey(),
                  //   height: 240,
                  //   fit: BoxFit.fill,
                  //   placeholder: (context, url) => const Center(
                  //     child: CircularProgressIndicator(),
                  //   ),
                  //   errorWidget: (context, url, error) => const Center(
                  //     child: Icon(
                  //       Icons.error,
                  //       color: Colors.red,
                  //     ),
                  //   ),
                  // ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withOpacity(0),
                          AppColors.gray,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 20,
                            left: 15,
                            right: 15,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.playlistModel.title,
                                  style: const TextStyle(
                                    fontFamily: 'TTNorms',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.playlistModel.taleModels.length} аудио',
                                    style: const TextStyle(
                                      fontFamily: 'TTNorms',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  Text(
                                    //!Переделать
                                    // sumAudioDuration?.inMilliseconds.toString() ?? '',
                                    '${convertDurationToString(
                                      duration: widget.playlistModel.taleModels
                                          .fold<Duration>(
                                        Duration.zero,
                                        (Duration previousValue, element) =>
                                            previousValue + element.duration,
                                      ),
                                      formattingType:
                                          TimeFormattingType.hourMinute,
                                    )} ${widget.playlistModel.taleModels.fold<Duration>(
                                          Duration.zero,
                                          (Duration previousValue, element) =>
                                              previousValue + element.duration,
                                        ).inHours > 0 ? "часа" : "минут"}',
                                    style: const TextStyle(
                                      fontFamily: 'TTNorms',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
