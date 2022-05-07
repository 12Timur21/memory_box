import 'package:flutter/material.dart';
import 'package:memory_box/screens/login_screen/registration_screens/registration_screen.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/elipse_orange_button.dart';
import 'package:memory_box/screens/login_screen/widgets/textLogo.dart';

class WelcomeRegistrationScreen extends StatelessWidget {
  static const routeName = 'WelcomeRegistrationScreen';

  const WelcomeRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _navigateToRegistration() {
      Navigator.pushNamed(
        context,
        RegistrationScreen.routeName,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BackgroundPattern(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 275,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const TextLogo(),
                ),
                const SizedBox(
                  height: 50,
                ),
                Column(
                  children: <Widget>[
                    const Text(
                      'Привет!',
                      style: TextStyle(
                        fontFamily: 'TTNorms',
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Мы рады видеть тебя здесь. \n Это приложение поможет записывать \n сказки и держать их в удобном месте не \n заполняя память на телефоне',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'TTNorms',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    ElipseOrangeButton(
                      text: 'Продолжить',
                      onPress: _navigateToRegistration,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
