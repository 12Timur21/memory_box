import 'package:bloc/bloc.dart';
import 'package:memory_box/models/user_model.dart';
import 'package:memory_box/repositories/auth_service.dart';
part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final AuthService _authService = AuthService.instance;

  RegistrationBloc() : super(LoginInitial());

  @override
  Stream<RegistrationState> mapEventToState(RegistrationEvent event) async* {
    if (event is VerifyPhoneNumber) {
      await _authService.verifyPhoneNumberAndSendOTP(
        phoneNumber: event.phoneNumber,
        codeAutoRetrievalTimeout: () {
          emit(VerifyTimeEnd());
        },
        codeSent: (String verficationIds, int? resendingToken) {
          emit(VerifyPhoneNumberSucces(
            verificationIds: verficationIds,
            resendingToken: resendingToken,
          ));
        },
        verificationFailed: (String? error) {
          emit(VerifyPhoneNumberFailure(error: error));
        },
        verificationCompleted: (_) {},
      );
    }
    if (event is VerifyOTPCode) {
      UserModel? userModel = await _authService.verifyOTPCode(
        smsCode: event.smsCode,
        verifictionId: event.verifictionId,
      );

      if (userModel != null) {
        yield VerifyOTPSucces(user: userModel);
      } else {
        yield VerifyOTPFailure();
      }
    }

    if (event is AnonRegistration) {
      UserModel? userModel = await _authService.signInAnon();
      if (userModel != null) {
        yield AnonRegistrationSucces(user: userModel);
      } else {
        yield AnonRegistrationFailrule();
      }
    }

    if (event is LoadLoadingPage) {
      yield LoginPageLoaded();
    }
  }
}
