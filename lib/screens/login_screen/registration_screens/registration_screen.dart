import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:memory_box/blocks/registration/registration_bloc.dart';
import 'package:memory_box/blocks/session/session_bloc.dart';
import 'package:memory_box/screens/login_screen/registration_screens/verifyOTP_screen.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/circle_textField.dart';
import 'package:memory_box/widgets/elipse_orange_button.dart';
import 'package:memory_box/screens/login_screen/widgets/hintPlate.dart';

class RegistrationScreen extends StatefulWidget {
  static const routeName = 'RegistrationScreen';

  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<RegistrationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void anonAuth() async {
    BlocProvider.of<RegistrationBloc>(context).add(
      AnonRegistration(),
    );
  }

  void verifyPhoneNumber() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());
      BlocProvider.of<RegistrationBloc>(context).add(
        VerifyPhoneNumber(
          phoneNumber: toNumericString(_phoneController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      listener: (BuildContext context, state) {
        //*[Start] AnonSession
        if (state is AnonRegistrationSucces) {
          BlocProvider.of<SessionBloc>(context).add(
            LogIn(SessionStatus.anonAuthenticated),
          );
        }
        if (state is AnonRegistrationFailrule) {
          const SnackBar snackBar = SnackBar(
            content: Text(
              'Произошла какая-то ошибка c анонимным входом, попробуйте позже',
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        //*[END] AnonSession

        //*[Start] PhoneNumberSession
        if (state is VerifyPhoneNumberSucces) {
          Navigator.pushNamed(
            context,
            VerifyOTPScreen.routeName,
            arguments: state.verificationIds,
          );
        }
        if (state is VerifyPhoneNumberFailure) {
          const SnackBar snackBar = SnackBar(
            content: Text(
              'Произошла какая-то ошибка во время проверки вашего номера телефона, попробуйте ещё раз',
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        //*[END] PhoneNumberSession
      },
      child: Scaffold(
        body: BackgroundPattern(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 275,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                'Регистрация',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'TTNorms',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 6,
                                  fontSize: 48,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      const Text(
                        'Введи номер телефона',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'TTNorms',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _formKey,
                        child: CircleTextField(
                          controller: _phoneController,
                          inputFormatters: [PhoneInputFormatter()],
                          validator: (value) {
                            int length = toNumericString(value).length;

                            if (length < 8) {
                              return 'Укажите полный номер телефона';
                            }
                            if (value == null || value.isEmpty) {
                              return 'Поле не может быть пустым';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      ElipseOrangeButton(
                        text: 'Продолжить',
                        onPress: verifyPhoneNumber,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextButton(
                        onPressed: anonAuth,
                        child: const Text(
                          'Позже',
                          style: TextStyle(
                            fontFamily: 'TTNorms',
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const HintPlate(
                        label:
                            'Регистрация привяжет твои сказки \n к облаку, после чего они всегда \n будут с тобой',
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
