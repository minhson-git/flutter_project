import 'package:flutter/material.dart';
import '../presentation/home_screen/home_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String homeScreen = '/home-screen';


  static Map<String, WidgetBuilder> routes = {
    homeScreen: (context) => const HomeScreen(),
    // TODO: Add your other routes here
  };
}
