import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/models/playlist_model.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/utils/formatting.dart';

class SelectPlaylistTile extends StatefulWidget {
  const SelectPlaylistTile({
    required this.playlistModel,
    required this.onSelect,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  final PlaylistModel playlistModel;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  _SelectPlaylistTileState createState() => _SelectPlaylistTileState();
}

class _SelectPlaylistTileState extends State<SelectPlaylistTile> {
  bool isSelect = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelect,
      child: SizedBox(
        height: 240,
        width: 190,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.playlistModel.coverUrl,
                    height: 240,
                    fit: BoxFit.fill,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
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
                  Container(
                    color: isSelect ? null : Colors.black.withOpacity(0.4),
                    child: Center(
                      child: widget.isSelected
                          ? SvgPicture.asset(
                              AppIcons.submitCircle,
                              color: Colors.white,
                            )
                          : SvgPicture.asset(
                              AppIcons.circle,
                              color: Colors.white,
                            ),
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
