import 'package:app/presentations/auth/signUp/signup_screen.dart';
import 'package:app/routing/routes.dart';
import 'package:flutter/material.dart';

import '../presentations/auth/login/login_screen.dart';
import '../presentations/onboarding/onboarding_screen.dart';

class AppRouter {
  AppRouter();
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      default:
        return null;
    }
  }
}
