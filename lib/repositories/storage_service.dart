import 'dart:core';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:memory_box/models/tale_model.dart';

import 'package:memory_box/repositories/auth_service.dart';
import 'package:memory_box/repositories/database_service.dart';

enum FileType {
  tale,
  file,
  avatar,
  playlistCover,
}

class StorageService {
  static final FirebaseStorage _cloud = FirebaseStorage.instance;
  StorageService._();
  static StorageService instance = StorageService._();

  final DatabaseService _database = DatabaseService.instance;

  Reference createTaleReference(String taleID) {
    final String destination = mapDestination(
      fileType: FileType.tale,
      uid: AuthService.userID,
      fileName: taleID,
    );

    return _cloud.ref().child(destination);
  }

  String mapDestination({
    required FileType fileType,
    String? uid,
    String? fileName,
  }) {
    String destination = '';
    String src = '';
    if (fileType == FileType.file) destination = 'files';
    if (fileType == FileType.tale) destination = 'audiofiles';
    if (fileType == FileType.avatar) destination = 'avatars';
    if (fileType == FileType.playlistCover) destination = 'playlistCovers';

    if (uid != null) src = '/$destination/$uid';
    if (fileName != null) src = '/$destination/$fileName';
    if (uid == null && fileName == null) src = destination;
    if (uid != null && fileName != null) src = '/$destination/$uid/$fileName';

    return src;
  }

  //??[Start] File

  Future<int> filesLength({
    required FileType fileType,
  }) async {
    final destination = mapDestination(
      fileType: fileType,
      uid: AuthService.userID,
    );
    ListResult listResult = await _cloud.ref().child(destination).listAll();

    return listResult.items.length;
  }

  Future<bool> isFileExist({
    required FileType fileType,
    required String fileName,
  }) async {
    final destination = mapDestination(
      fileType: fileType,
      fileName: fileName,
    );

    String fileUrl = await _cloud
        .ref()
        .child(
          destination,
        )
        .getDownloadURL();

    if (fileUrl.isNotEmpty) return true;
    return false;
  }

  Future<String> getFileUrl({
    required FileType fileType,
    required String fileName,
  }) async {
    final destination = mapDestination(
      fileType: fileType,
      fileName: fileName,
    );

    String downloadUrl = await _cloud
        .ref()
        .child(
          destination,
        )
        .getDownloadURL();

    return downloadUrl;
  }

  Future<String?> uploadFile({
    required File file,
    required FileType fileType,
    String? fileName,
  }) async {
    final String destination = mapDestination(
      fileType: fileType,
      uid: AuthService.userID,
      fileName: fileName,
    );

    await _cloud.ref().child(destination).putFile(
          file,
        );

    return await _cloud.ref().child(destination).getDownloadURL();
  }
  //??[End] File

  //??[Start] Tale

  Future<void> uploadTaleFile({
    required File file,
    required TaleModel taleModel,
  }) async {
    final String destination = mapDestination(
      fileType: FileType.tale,
      uid: AuthService.userID,
      fileName: taleModel.ID,
    );

    try {
      await _cloud.ref().child('/$destination').putFile(file);

      String url = await _cloud.ref().child('/$destination').getDownloadURL();

      await _database.createTale(
        taleModel: taleModel.copyWith(
          url: url,
        ),
      );
    } on FirebaseException catch (_) {}
  }

  Future<void> deleteTale({
    required String taleID,
  }) async {
    final destination = mapDestination(
      uid: AuthService.userID,
      fileName: taleID,
      fileType: FileType.tale,
    );

    await _cloud.ref().child('/$destination').delete();
  }

  //??[End] Tale

  //??[Start] Playlist
  Future<String> uploadPlayListCover({
    required File file,
    required String coverID,
  }) async {
    final String destination = mapDestination(
      uid: AuthService.userID,
      fileName: coverID,
      fileType: FileType.playlistCover,
    );

    await _cloud.ref().child(destination).putFile(file);
    return await _cloud.ref().child(destination).getDownloadURL();
  }

  Future<void> deletePlaylistCover({
    required String coverID,
  }) async {
    final destination = mapDestination(
      uid: AuthService.userID,
      fileName: coverID,
      fileType: FileType.playlistCover,
    );

    await _cloud.ref().child('/$destination').delete();
  }

  Future<void> getPlayListCoverURL({
    required String coverID,
  }) async {
    final destination = mapDestination(
      uid: AuthService.userID,
      fileName: coverID,
      fileType: FileType.playlistCover,
    );

    await _cloud.ref().child('/$destination').getDownloadURL();
  }
  //??[End] Playlist
}
