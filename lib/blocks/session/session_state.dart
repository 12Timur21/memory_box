part of 'session_bloc.dart';

enum SessionStatus {
  initial,
  authenticated,
  anonAuthenticated,
  notAuthenticated,
  failure,
}

class SessionState {
  final SessionStatus status;
  final UserModel? user;

  const SessionState({
    this.status = SessionStatus.initial,
    this.user,
  });
}
