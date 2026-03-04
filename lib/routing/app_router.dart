import 'package:app/presentations/complains/complains_screen.dart';
import 'package:app/routing/routes.dart';
import 'package:flutter/material.dart';

import '../presentations/auth/login/login_screen.dart';
import '../presentations/auth/signUp/signup_screen.dart';
import '../presentations/complains/add_complaint_screen.dart';
import '../presentations/forget_password/forget_password_screen.dart';
import '../presentations/forget_password/new_password_screen.dart';
import '../presentations/forget_password/otp_screen.dart';
import '../presentations/home/home_screen_state.dart';
import '../presentations/notifications/notification_screen.dart';
import '../presentations/onboarding/onboarding_screen.dart';

class AppRouter {
  AppRouter();
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case Routes.homeScreenState:
        return MaterialPageRoute(builder: (_) => const HomeScreenState());
      case Routes.addComplaintScreen:
        return MaterialPageRoute(builder: (_) => const AddComplaintScreen());
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signUpRoute:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case Routes.forgetPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());
      case Routes.otpScreenRoute:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case Routes.newPasswordRoute:
        return MaterialPageRoute(builder: (_) => const NewPasswordScreen());
      case Routes.notificationsScreen:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case Routes.complainsScreen:
        return MaterialPageRoute(builder: (_) => const ComplainsScreen());
      default:
        return null;
    }
  }
}
