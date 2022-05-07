import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:memory_box/models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  const AuthService._();
  static const AuthService instance = AuthService._();

  static String? userID;

  Future<UserModel?> currentUser() async {
    String? uid = _auth.currentUser?.uid;
    userID = uid;
    if (uid != null) {
      bool isUserExist = await DatabaseService.instance.isUserExist();
      if (isUserExist) {
        UserModel? userModel =
            await DatabaseService.instance.userModelFromDatabase();

        return userModel;
      }
    }
    return null;
  }

  Future<void> verifyPhoneNumberAndSendOTP({
    required String phoneNumber,
    required VoidCallback codeAutoRetrievalTimeout,
    required void Function(String?) verificationFailed,
    required void Function(PhoneAuthCredential credential)
        verificationCompleted,
    required void Function(String, int?) codeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+$phoneNumber',
      timeout: const Duration(seconds: 100),
      verificationCompleted: (PhoneAuthCredential credential) {
        verificationCompleted(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e.message);
      },
      codeSent: (verficationIds, resendingToken) {
        codeSent(verficationIds, resendingToken);
      },
      codeAutoRetrievalTimeout: (_) {
        if (_auth.currentUser == null) {
          codeAutoRetrievalTimeout();
        }
      },
    );
  }

  Future<UserModel?> verifyOTPCode({
    required String smsCode,
    required String verifictionId,
  }) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verifictionId,
      smsCode: smsCode,
    );
    return await _signInWithPhoneAuthCredential(phoneAuthCredential);
  }

  Future<UserModel?> _signInWithPhoneAuthCredential(
    PhoneAuthCredential phoneAuthCredential,
  ) async {
    try {
      UserCredential result =
          await _auth.signInWithCredential(phoneAuthCredential);
      String? uid = result.user?.uid;
      if (uid != null) {
        userID = uid;
        UserModel? userModel;
        User? user = result.user;

        bool isUserExist = await DatabaseService.instance.isUserExist();

        if (isUserExist) {
          userModel = await DatabaseService.instance.userModelFromDatabase();
        } else {
          if (user != null) {
            userModel = _firebaseModeltoUserModel(user);
            if (userModel != null) {
              DatabaseService.instance.recordNewUser(userModel);
            }
          }
        }
        return userModel;
      }
    } on FirebaseAuthException catch (_) {
      return null;
    }
  }

  Future<UserModel?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;

      UserModel? userModel = _firebaseModeltoUserModel(user);
      if (userModel != null) {
        DatabaseService.instance.recordNewUser(userModel);
        userID = userModel.uid;
      }
      return userModel;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    userID = null;
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  UserModel? _firebaseModeltoUserModel(User? user) {
    return user != null
        ? UserModel(
            uid: user.uid,
            phoneNumber: user.phoneNumber,
            displayName: user.displayName,
          )
        : null;
  }

  bool isAuth() {
    return _auth.currentUser == null ? false : true;
  }

  Future<void> updatePhoneNumber(
    PhoneAuthCredential phoneAuthCredential,
  ) async {
    _auth.currentUser?.updatePhoneNumber(phoneAuthCredential);
  }
}
