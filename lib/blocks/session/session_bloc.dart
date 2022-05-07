import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:memory_box/models/user_model.dart';
import 'package:memory_box/repositories/auth_service.dart';
import 'package:memory_box/repositories/database_service.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc()
      : super(const SessionState(
          status: SessionStatus.initial,
        ));

  final AuthService _authService = AuthService.instance;
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Stream<SessionState> mapEventToState(
    SessionEvent event,
  ) async* {
    if (event is InitSession) {
      UserModel? currentUser = await _authService.currentUser();
      String? phoneNumber = currentUser?.phoneNumber;

      if (currentUser != null) {
        yield SessionState(
          status: phoneNumber == null || phoneNumber.isEmpty
              ? SessionStatus.anonAuthenticated
              : SessionStatus.authenticated,
          user: currentUser,
        );
      } else {
        yield const SessionState(
          status: SessionStatus.notAuthenticated,
          user: null,
        );
      }
    }

    if (event is LogIn) {
      UserModel? currentUser = await _authService.currentUser();

      yield SessionState(
        status: event.sessionStatus,
        user: currentUser,
      );
    }

    if (event is LogOut) {
      await _authService.signOut();

      yield const SessionState(
        status: SessionStatus.notAuthenticated,
        user: null,
      );
    }

    if (event is DeleteAccount) {
      await _databaseService.deleteUserFromFirebase();
      await _authService.deleteAccount();

      yield const SessionState(
        status: SessionStatus.notAuthenticated,
        user: null,
      );
    }

    if (event is UpdateAccount) {
      yield SessionState(
        status: event.sessionStatus ?? state.status,
        user: state.user?.copyWith(
          displayName: event.displayName ?? state.user?.displayName,
          phoneNumber: event.phoneNumber ?? state.user?.phoneNumber,
          subscriptionType:
              event.subscriptionType ?? state.user?.subscriptionType,
          avatarUrl: event.avatarUrl ?? state.user?.avatarUrl,
        ),
      );
    }
  }
}
