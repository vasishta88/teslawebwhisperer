import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teslawebwhisperer/services/local_services.dart';
import 'main.dart';

/*
class LocaleApp extends StatelessWidget {
  const LocaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: LocalGovernment.supportLocale(),
      path: LocalGovernment.path,
      startLocale: LocalGovernment.english.locale,
      child: Builder(
        builder: (innerContext) {
          print("Current Locale: ${innerContext.locale}");
          return MyApp();
        },
      ),
    );
  }

}

 */

import 'package:teslawebwhisperer/services/app_routes.dart'; // Import for routes

class LocaleApp extends StatelessWidget {
  const LocaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: LocalGovernment.supportLocale(),
      path: LocalGovernment.path,
      startLocale: LocalGovernment.english.locale,
      child: Builder(
        builder: (innerContext) {
          print("Current Locale: ${innerContext.locale}");
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: innerContext.localizationDelegates,
            supportedLocales: innerContext.supportedLocales,
            locale: innerContext.locale,
            theme: ThemeData(
              useMaterial3: true,
            ),
            routes: AppRoutes.routes,
            // You can set the home or initialRoute property as needed
            home: MyApp(), // or you can use 'initialRoute: "/yourRouteName"'
          );
        },
      ),
    );
  }
}
