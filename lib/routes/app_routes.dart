import 'package:flutter/material.dart';
import '../presentation/auth_screen/auth_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String homeScreen = '/home-screen';
  static const String authScreen = '/auth-screen';
  static const String categoriesScreen = '/categories-screen';
  static const String searchScreen = '/search-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    authScreen: (context) => const AuthScreen(),
    homeScreen: (context) => const HomeScreen(),

    // TODO: Add your other routes here
  };
}
