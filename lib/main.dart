import 'package:app/routing/app_router.dart';
import 'package:app/routing/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';

import 'app/nazra_app.dart';
import 'app/provider/language_provider.dart';
import 'app/provider/theme_provider.dart';
import 'firebase_options.dart';

// Bloc imports

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await ScreenUtil.ensureScreenSize();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ FCM Setup
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Print FCM Token for testing
  final fcmToken = await messaging.getToken();
  print('FCM Token: $fcmToken');

  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  // Background/Terminated tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    navigatorKey.currentState?.pushNamed(Routes.notificationsScreen);
  });

  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState?.pushNamed(Routes.notificationsScreen);
    });
  }

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final languageCode = prefs.getString('languageCode') ?? 'en';

  // Initialize services
  final appRouter = AppRouter();

  // Determine Initial Route
  //final user = await authRepository.currentUser;
  String initialRoute = Routes.onboardingRoute;

  // final cloudDNS = dotenv.env['CLOUDINARY_CLOUD_DNS'];
  // if (cloudDNS == null || cloudDNS.isEmpty) {
  //   throw StateError(
  //     'CLOUDINARY_CLOUD_DNS is not set. Please add it to your .env file.',
  //   );
  // }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(isDarkMode),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(languageCode),
        ),
      ],
      // child: MultiBlocProvider(
      //   providers: [
      //
      //   ],
        child: NazraApp.getInstance(appRouter, navigatorKey, initialRoute),
 //     ),
    ),
  );
}
