import 'package:app/routing/routes.dart';
import 'package:flutter/material.dart';

import '../presentations/onboarding/onboarding_screen.dart';

class AppRouter {
  AppRouter();
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      default:
        return null;
    }
  }
}
