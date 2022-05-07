import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';

class TaleListTileWithPopupMenu extends StatefulWidget {
  const TaleListTileWithPopupMenu({
    required this.taleModel,
    required this.tooglePlayMode,
    required this.onRename,
    required this.onUndoRenaming,
    required this.onAddToPlaylist,
    required this.onDelete,
    required this.onShare,
    this.playButtonColor = AppColors.lightBlue,
    this.isPlayMode = false,
    Key? key,
  }) : super(key: key);

  final TaleModel taleModel;
  final bool isPlayMode;
  final Color playButtonColor;

  final VoidCallback tooglePlayMode;

  final Function(String) onRename;
  final VoidCallback onUndoRenaming;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  @override
  _TaleListTileWithPopupMenuState createState() =>
      _TaleListTileWithPopupMenuState();
}

class _TaleListTileWithPopupMenuState extends State<TaleListTileWithPopupMenu> {
  late final TextEditingController _textFieldController;

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController(
      text: widget.taleModel.title,
    );
  }

  void _renameTale() {
    widget.onRename(_textFieldController.text);
  }

  void _onUndoRename() {
    widget.onUndoRenaming();
  }

  void _openEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(41),
        color: AppColors.wildSand,
        border: Border.all(
          color: AppColors.darkPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        leading: GestureDetector(
          onTap: widget.tooglePlayMode,
          child: SvgPicture.asset(
            widget.isPlayMode ? AppIcons.stopCircle : AppIcons.playCircle,
            color: widget.playButtonColor,
            // width: 50,
          ),
        ),
        title: TextFormField(
          enabled: _isEditMode,
          controller: _textFieldController,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value?.isEmpty == true || value == null) {
              return 'Название не может быть пустым';
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            isDense: true,
            border: _isEditMode
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                  )
                : InputBorder.none,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
          ),
        ),
        horizontalTitleGap: 20,
        subtitle: _isEditMode
            ? null
            : Text(
                widget.taleModel.duration.inMinutes != 0
                    ? '${widget.taleModel.duration.inMinutes} минут'
                    : '${widget.taleModel.duration.inSeconds} секунд',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'TTNorms',
                  fontWeight: FontWeight.normal,
                  color: AppColors.darkPurple.withOpacity(0.5),
                  letterSpacing: 0.1,
                ),
              ),
        trailing: _isEditMode
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _renameTale,
                    icon: const Icon(
                      Icons.task_alt,
                    ),
                  ),
                  IconButton(
                    onPressed: _onUndoRename,
                    icon: const Icon(
                      Icons.cancel,
                    ),
                  )
                ],
              )
            : PopupMenuButton(
                elevation: 10,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                icon: SvgPicture.asset(
                  AppIcons.more,
                  color: Colors.black,
                  width: 25,
                ),
                onSelected: (result) {
                  switch (result) {
                    case 0:
                      _openEditMode();
                      break;
                    case 1:
                      widget.onAddToPlaylist();
                      break;
                    case 2:
                      widget.onDelete();
                      break;
                    case 3:
                      widget.onShare();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 0,
                      child: _isEditMode
                          ? const Text('Сохранить')
                          : const Text('Переименовать'),

                      // onTap: _openEditMode,
                    ),
                    const PopupMenuItem(
                      value: 1,
                      child: Text('Добавить в подборку'),
                      // onTap: _addToPlayList,
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('Удалить'),
                      // onTap: ,
                    ),
                    const PopupMenuItem(
                      value: 3,
                      child: Text('Поделиться'),
                      // onTap: ,
                    )
                  ];
                },
              ),
      ),
    );
  }
}
