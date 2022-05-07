import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memory_box/blocks/session/session_bloc.dart';
import 'package:memory_box/screens/login_screen/login_screens/welcome_regular_user_screen.dart';
import 'package:memory_box/screens/login_screen/registration_screens/welcome_registration_screen.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = 'SplashScreen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      context.read<SessionBloc>().add(InitSession());
    });

    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state.status == SessionStatus.authenticated ||
            state.status == SessionStatus.anonAuthenticated) {
          Navigator.pushNamed(
            context,
            WelcomeRegualrUserScreen.routeName,
          );
        }
        if (state.status == SessionStatus.notAuthenticated) {
          Navigator.pushNamed(
            context,
            WelcomeRegistrationScreen.routeName,
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromRGBO(128, 119, 228, 1),
              Color.fromRGBO(195, 132, 200, 1),
              Color.fromRGBO(255, 144, 175, 1),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MemoryBox',
              style: TextStyle(
                fontFamily: 'TTNorms',
                fontWeight: FontWeight.bold,
                fontSize: 50,
                letterSpacing: 0.6,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SvgPicture.asset(
              'assets/icons/Logo.svg',
            ),
          ],
        ),
      ),
    );
  }
}
