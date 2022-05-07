import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memory_box/screens/mainPage.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/screens/login_screen/widgets/hintPlate.dart';

class WelcomeRegualrUserScreen extends StatelessWidget {
  static const routeName = 'WelcomeRegualrUserScreen';

  const WelcomeRegualrUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 3),
      () => Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        MainPage.routeName,
        (route) => false,
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BackgroundPattern(
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
            ),
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
                          'MemoryBox',
                          style: TextStyle(
                            letterSpacing: 6,
                            fontSize: 48,
                            fontFamily: 'TTNorms',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'Твой голос всегда рядом',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2,
                          color: Colors.white,
                          fontFamily: 'TTNorms',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  child: const Text(
                    'Мы рады тебя видеть',
                    style: TextStyle(
                      fontFamily: 'TTNorms',
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      letterSpacing: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 21,
                    vertical: 25,
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(246, 246, 246, 1),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.11),
                        // spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 4), // changes position of shadow
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                SvgPicture.asset('assets/icons/Heart.svg'),
                const Spacer(),
                const HintPlate(
                  label:
                      'Взрослые иногда нуждаются в \n сказке даже больше, чем дети',
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
