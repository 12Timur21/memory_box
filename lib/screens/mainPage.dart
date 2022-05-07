import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/bottom_navigation_index_control/bottom_navigation_index_control_cubit.dart';
import 'package:memory_box/routes/app_router.dart';
import 'package:memory_box/screens/home_screen/home_screen.dart';
import 'package:memory_box/screens/recording_screen/recording_barrel.dart';

import 'package:memory_box/widgets/bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:memory_box/widgets/drawer/custom_drawer.dart';

class MainPage extends StatefulWidget {
  static const routeName = 'MainPage';

  const MainPage({Key? key}) : super(key: key);
  static final GlobalKey<NavigatorState> navigationKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> recordingNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isOpenBottomSheet = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showBottomSheet() {
    isOpenBottomSheet = true;
    _scaffoldKey.currentState
        ?.showBottomSheet(
          (BuildContext context) {
            return BlocProvider(
              create: (context) => AudioplayerBloc(),
              child: Navigator(
                key: MainPage.recordingNavigatorKey,
                onGenerateRoute: AppRouter.generateRoute,
                initialRoute: RecordingScreen.routeName,
              ),
            );
          },
          backgroundColor: Colors.transparent,
        )
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              BlocProvider.of<BottomNavigationIndexControlCubit>(context)
                  .changeIcon(
                RecorderButtonStates.withIcon,
              );

              isOpenBottomSheet = false;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: Navigator(
        key: MainPage.navigationKey,
        initialRoute: HomeScreen.routeName,
        onGenerateRoute: AppRouter.generateRoute,
      ),
      bottomNavigationBar: BottomNavBar(
        openButtomSheet: _showBottomSheet,
      ),
    );
  }
}
