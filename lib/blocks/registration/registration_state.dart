part of 'registration_bloc.dart';

abstract class RegistrationState {}

class LoginInitial extends RegistrationState {}

class LoginPageLoaded extends RegistrationState {}

class LoginLoading extends RegistrationState {}

class LoginSuccess extends RegistrationState {}

class LoginFailure extends RegistrationState {
  final String error;

  LoginFailure({required this.error});
}

class VerifyPhoneNumberSucces extends RegistrationState {
  final String verificationIds;
  final int? resendingToken;

  VerifyPhoneNumberSucces({
    required this.verificationIds,
    this.resendingToken,
  });
}

class VerifyPhoneNumberFailure extends RegistrationState {
  final String? error;

  VerifyPhoneNumberFailure({required this.error});
}

class VerifyOTPSucces extends RegistrationState {
  final UserModel user;

  VerifyOTPSucces({required this.user});
}

class VerifyOTPFailure extends RegistrationState {
  final String? error;

  VerifyOTPFailure({this.error});
}

class VerifyTimeEnd extends RegistrationState {}

class AnonRegistrationSucces extends RegistrationState {
  final UserModel user;

  AnonRegistrationSucces({required this.user});
}

class AnonRegistrationFailrule extends RegistrationState {}
