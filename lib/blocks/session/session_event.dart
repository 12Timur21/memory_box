part of 'session_bloc.dart';

abstract class SessionEvent {
  const SessionEvent();
}

class InitSession extends SessionEvent {}

class LogIn extends SessionEvent {
  SessionStatus sessionStatus;

  LogIn(this.sessionStatus);
}

class LogOut extends SessionEvent {}

class DeleteAccount extends SessionEvent {
  final String uid;

  DeleteAccount({
    required this.uid,
  });
}

class UpdateAccount extends SessionEvent {
  String? displayName;
  String? phoneNumber;
  SubscriptionType? subscriptionType;
  SessionStatus? sessionStatus;
  String? avatarUrl;

  UpdateAccount({
    this.sessionStatus,
    this.displayName,
    this.phoneNumber,
    this.subscriptionType,
    this.avatarUrl,
  });
}
