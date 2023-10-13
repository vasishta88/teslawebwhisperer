import 'package:flutter/cupertino.dart';
import 'package:teslawebwhisperer/screens/charge_screen.dart';
import 'package:teslawebwhisperer/screens/climate_screen.dart';
import 'package:teslawebwhisperer/screens/control_screen.dart';
import 'package:teslawebwhisperer/screens/home_screen.dart';
import 'package:teslawebwhisperer/screens/intro_page.dart';
import 'package:teslawebwhisperer/screens/lock_screen.dart';

class HomeScreenArguments {
  final String accessToken;
  final Map<String, dynamic> userDetails;
  final Map<String, dynamic> vehicleData;
  final String vehicleID;

  HomeScreenArguments({
    required this.accessToken,
    required this.userDetails,
    required this.vehicleData,
    required this.vehicleID,
  });
}


class ClimateScreenArguments {
  final String accessToken;
  final Map<String, dynamic> userDetails;
  final Map<String, dynamic> vehicleData;
  final String vehicleID;

  ClimateScreenArguments({
    required this.accessToken,
    required this.userDetails,
    required this.vehicleData,
    required this.vehicleID,
  });
}



class AppRoutes {
  AppRoutes._();

  static final routes = {
    ChargerScreen.id: (context) => const ChargerScreen(),
    //ClimateScreen.id: (context) => const ClimateScreen(),
    ControlScreen.id: (context) => const ControlScreen(),

    // HomeScreen.id: (context) {
    // String token = ModalRoute.of(context)!.settings.arguments as String;
    // return HomeScreen(accessToken: token);
    // }

    ClimateScreen.id: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as ClimateScreenArguments;
      return ClimateScreen(
        accessToken: args.accessToken,
        userDetails: args.userDetails,
        vehicleData: args.vehicleData,
        vehicleID: args.vehicleID,
      );
    },


    HomeScreen.id: (context) {
  final args = ModalRoute.of(context)!.settings.arguments as HomeScreenArguments;
  return HomeScreen(
  accessToken: args.accessToken,
  userDetails: args.userDetails,
  vehicleData: args.vehicleData,
  vehicleID: args.vehicleID,
  );
  },

    LockScreen.id: (context) => const LockScreen(),
    IntroScreen.id: (context) => const IntroScreen(),
  };

  static void pushReplacementLockScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, LockScreen.id);
  }

  static void pushReplacementHomeScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, HomeScreen.id);
  }

  static void pushClimateScreen(
      BuildContext context, {
        required String accessToken,
        required Map<String, dynamic> userDetails,
        required Map<String, dynamic> vehicleData,
        required String vehicleID,
      }) {
    Navigator.pushNamed(
      context,
      ClimateScreen.id,
      arguments: ClimateScreenArguments(
        accessToken: accessToken,
        userDetails: userDetails,
        vehicleData: vehicleData,
        vehicleID: vehicleID,
      ),
    );
  }

/*
  static void pushClimateScreen(BuildContext context) {
    Navigator.pushNamed(context, ClimateScreen.id);
  }*/

  static void pushChargeScreen(BuildContext context) {
    Navigator.pushNamed(context, ChargerScreen.id);
  }

  static void pushControlScreen(BuildContext context) {
    Navigator.pushNamed(context, ControlScreen.id);
  }

  static void pushIntroScreen(BuildContext context) {
    Navigator.pushNamed(context, IntroScreen.id);
  }

  static void popBack(BuildContext context) {
    Navigator.pop(context);
  }
}
