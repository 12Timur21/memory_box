import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:memory_box/blocks/registration/registration_bloc.dart';
import 'package:memory_box/blocks/session/session_bloc.dart';
import 'package:memory_box/screens/login_screen/registration_screens/gratiude_registration_screen.dart';
import 'package:memory_box/screens/login_screen/registration_screens/registration_screen.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/circle_textField.dart';
import 'package:memory_box/widgets/elipse_orange_button.dart';
import 'package:memory_box/screens/login_screen/widgets/hintPlate.dart';

class VerifyOTPScreen extends StatefulWidget {
  static const routeName = 'VerifyPin';

  VerifyOTPScreen({
    required this.verficationId,
    Key? key,
  }) : super(key: key);

  String verficationId;

  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    void _verifySMSCode() async {
      if (_formKey.currentState!.validate()) {
        FocusScope.of(context).requestFocus(FocusNode());
        BlocProvider.of<RegistrationBloc>(context).add(
          VerifyOTPCode(
            smsCode: _otpController.text,
            verifictionId: widget.verficationId,
          ),
        );
      }
    }

    void _cancelRegistration() {
      Navigator.pushNamed(
        context,
        RegistrationScreen.routeName,
      );
    }

    return BlocListener<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        if (state is VerifyOTPSucces) {
          BlocProvider.of<SessionBloc>(context).add(
            LogIn(SessionStatus.authenticated),
          );
          Navigator.pushNamed(
            context,
            GratitudeRegistrationScreen.routeName,
          );
        }
        if (state is VerifyOTPFailure) {
          const snackBar = SnackBar(
            content: Text('Произошла какая-то ошибка, попробуйте ещё раз'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        if (state is VerifyTimeEnd) {
          SnackBar snackBar = SnackBar(
            duration: const Duration(seconds: 5),
            content: Builder(
              builder: (context) {
                int countdown = 5;
                Timer? timer;
                return StatefulBuilder(
                  builder: (context, setState) {
                    if (countdown > 0) {
                      timer = Timer(
                        const Duration(seconds: 1),
                        () {
                          setState(() {
                            countdown--;
                            timer?.cancel();
                          });
                        },
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        RegistrationScreen.routeName,
                      );
                    }
                    return Text(
                        'Истекло время проверки смс кода. Возвращение на главный экран через $countdown');
                  },
                );
              },
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Scaffold(
        body: BackgroundPattern(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: height,
                child: Column(
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
                      'Введи код из смс, чтобы мы тебя запомнили',
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
                        controller: _otpController,
                        inputFormatters: [],
                        maxLength: 6,
                        validator: (value) {
                          int length = toNumericString(value).length;

                          if (length < 6) {
                            return 'Укажите полный верификационный код';
                          }
                          if (value == null || value.isEmpty) {
                            return 'Поле не может быть пустым';
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ElipseOrangeButton(
                      text: 'Продолжить',
                      onPress: _verifySMSCode,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextButton(
                      onPressed: _cancelRegistration,
                      child: const Text(
                        'Отмена',
                        style: TextStyle(
                          fontFamily: 'TTNorms',
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Spacer(),
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
            ),
          ),
        ),
      ),
    );
  }
}
