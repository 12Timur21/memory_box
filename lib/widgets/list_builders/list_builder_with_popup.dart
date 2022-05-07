import 'package:flutter/material.dart';
import 'package:memory_box/blocks/list_builder/list_builder_bloc.dart';

class ListBuilderWithPopup extends StatefulWidget {
  const ListBuilderWithPopup({
    required this.initListBuilderEvent,
    Key? key,
  }) : super(key: key);

  final ListBuilderEvent initListBuilderEvent;

  @override
  _ListBuilderWithPopupState createState() => _ListBuilderWithPopupState();
}

class _ListBuilderWithPopupState extends State<ListBuilderWithPopup> {
  @override
  Widget build(BuildContext context) {
    return Container();
    // child: MultiBlocProvider(
    //   providers: [
    //     BlocProvider(
    //       create: (context) => ListBuilderBloc()
    //         ..add(
    //           widget.initListBuilderEvent,
    //         ),
    //     ),
    //     BlocProvider(
    //       create: (context) => AudioplayerBloc()
    //         ..add(
    //           InitPlayer(),
    //         ),
    //     ),
    //   ],
    //   // child:
    //   // BlocConsumer<ListBuilderBloc, ListBuilderState>(
    //   //   listener: (context, listBuilderState) {
    //   //     if (listBuilderState is PlayTaleState) {
    //   //       final TaleModel? taleModel =
    //   //           listBuilderState.currentPlayTaleModel;
    //   //       context.read<AudioplayerBloc>().add(
    //   //             Play(
    //   //               taleModel: taleModel!,
    //   //               isAutoPlay: true,
    //   //             ),
    //   //           );
    //   //     }

    //   //     if (listBuilderState is StopTaleState) {
    //   //       context.read<AudioplayerBloc>().add(
    //   //             Pause(),
    //   //           );
    //   //     }
    //   //   },
    //   //   builder: (context, listBuilderState) {
    //   //     return Stack(
    //   //       children: [
    //   //         Expanded(
    //   //           child: listBuilderState.isInit
    //   //               ? ListView.builder(
    //   //                   itemCount: listBuilderState.allTales.length,
    //   //                   itemBuilder: (context, index) {
    //   //                     TaleModel taleModel =
    //   //                         listBuilderState.allTales![index];
    //   //                     bool isPlay = false;

    //   //                     if (listBuilderState.currentPlayTaleIndex ==
    //   //                             index &&
    //   //                         listBuilderState.isPlay) {
    //   //                       isPlay = true;
    //   //                     }

    //   //                     return TaleListTileWithPopupMenu(
    //   //                       key: UniqueKey(),
    //   //                       isPlayMode: isPlay,
    //   //                       taleModel: taleModel,
    //   //                       onAddToPlaylist: () {},
    //   //                       onDelete: () {
    //   //                         context.read<ListBuilderBloc>().add(
    //   //                               DeleteTale(index),
    //   //                             );
    //   //                       },
    //   //                       onPause: () {
    //   //                         context.read<ListBuilderBloc>().add(
    //   //                               PlayTale(index),
    //   //                             );
    //   //                       },
    //   //                       onPlay: () {
    //   //                         context.read<ListBuilderBloc>().add(
    //   //                               StopTale(),
    //   //                             );
    //   //                       },
    //   //                       onRename: (String newTitle) {
    //   //                         context.read<ListBuilderBloc>().add(
    //   //                               RenameTale(
    //   //                                 taleModel.ID!,
    //   //                                 newTitle,
    //   //                               ),
    //   //                             );
    //   //                       },
    //   //                       onShare: () {
    //   //                         Share.share(taleModel.url!);
    //   //                       },
    //   //                       onUndoRenaming: () {
    //   //                         context.read<ListBuilderBloc>().add(
    //   //                               UndoRenameTale(),
    //   //                             );
    //   //                       },
    //   //                     );
    //   //                   },
    //   //                 )
    //   //               : const Center(
    //   //                   child: CircularProgressIndicator(),
    //   //                 ),
    //   //         ),
    //   //         BlocConsumer<AudioplayerBloc, AudioplayerState>(
    //   //           listener: (context, audioPlayerState) {
    //   //             if (audioPlayerState.isTaleEnd) {
    //   //               if (!listBuilderState.isPlayAllTalesMode) {
    //   //                 context.read<AudioplayerBloc>().add(
    //   //                       AnnulAudioPlayer(),
    //   //                     );
    //   //               }
    //   //               context.read<ListBuilderBloc>().add(
    //   //                     TaleEndPlay(),
    //   //                   );
    //   //             }
    //   //           },
    //   //           builder: (context, audioPlayerState) {
    //   //             if (listBuilderState.currentPlayTaleIndex == null) {
    //   //               return Container();
    //   //             }
    //   //             return Padding(
    //   //               padding: const EdgeInsets.only(
    //   //                 bottom: 10,
    //   //               ),
    //   //               child: Align(
    //   //                 alignment: Alignment.bottomCenter,
    //   //                 // child: AudioPlayer(
    //   //                 //   taleModel: audioPlayerState.taleModel,
    //   //                 //   currentPlayDuration:
    //   //                 //       audioPlayerState.currentPlayDuration,
    //   //                 //   isPlay: listBuilderState.isPlay,
    //   //                 //   next: () {
    //   //                 //     context.read<ListBuilderBloc>().add(NextTale());
    //   //                 //   },
    //   //                 //   pause: () {
    //   //                 //     context.read<ListBuilderBloc>().add(
    //   //                 //           StopTale(),
    //   //                 //         );
    //   //                 //   },
    //   //                 //   play: () {
    //   //                 //     context.read<ListBuilderBloc>().add(
    //   //                 //           PlayTale(
    //   //                 //             listBuilderState.currentPlayTaleIndex!,
    //   //                 //           ),
    //   //                 //         );
    //   //                 //   },
    //   //                 //   seek: (double durationInMs) {
    //   //                 //     context.read<AudioplayerBloc>().add(
    //   //                 //           Seek(
    //   //                 //             currentPlayTimeInSec: durationInMs,
    //   //                 //           ),
    //   //                 //         );
    //   //                 //   },
    //   //                 // ),
    //   //               ),
    //   //             );
    //   //           },
    //   //         ),
    //   //       ],
    //   //     );
    //   //   },
    //   // ),
    // ),
    // );
  }
}
