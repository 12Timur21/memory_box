part of 'registration_bloc.dart';

abstract class RegistrationEvent {}

class LoadLoadingPage extends RegistrationEvent {}

class VerifyPhoneNumber extends RegistrationEvent {
  final String phoneNumber;

  VerifyPhoneNumber({
    required this.phoneNumber,
  });
}

class AnonRegistration extends RegistrationEvent {}

class VerifyOTPCode extends RegistrationEvent {
  final String verifictionId;
  final String smsCode;

  VerifyOTPCode({
    required this.verifictionId,
    required this.smsCode,
  });
}
