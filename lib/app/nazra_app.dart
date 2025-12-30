import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../presentations/resources/theme_manager.dart';
import '../routing/app_router.dart';

class NazraApp extends StatefulWidget {
  const NazraApp({
    super.key,
    required this.appRouter,
    required this.navigatorKey,
    required this.initialRoute,
  });

  final AppRouter appRouter;
  final GlobalKey<NavigatorState> navigatorKey;
  final String initialRoute;

  static NazraApp? _instance;

  factory NazraApp.getInstance(
      AppRouter appRouter,
      GlobalKey<NavigatorState> navigatorKey,
      String initialRoute,
      ) {
    _instance ??= NazraApp(
      appRouter: appRouter,
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
    );
    return _instance!;
  }

  @override
  State<NazraApp> createState() => _NazraAppState();
}

class _NazraAppState extends State<NazraApp> {
  @override
  Widget build(BuildContext context) {
   // final themeProvider = context.watch<ThemeProvider>();
    //final languageProvider = context.watch<LanguageProvider>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp(
          navigatorKey: widget.navigatorKey,
          debugShowCheckedModeBanner: false,

          // ✅ Theme
          // theme: ThemeManager.getLightTheme(languageProvider.languageCode),
          // darkTheme: ThemeManager.getDarkTheme(languageProvider.languageCode),
          // themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // ✅ Localization
          locale: Locale("en"),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,

          // ✅ Routing
          initialRoute: widget.initialRoute,
          onGenerateRoute: widget.appRouter.onGenerateRoute,
        );
      },
    );
  }
}
