import 'package:flutter/material.dart';
import '../presentation/home_screen/home_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String authScreen = '/auth-screen';
  static const String categoriesScreen = '/categories-screen';
  static const String homeScreen = '/home-screen';
  static const String searchScreen = '/search-screen';
  static const String contentDetailScreen = '/content-detail-screen';
  static const String profileScreen = '/profile-screen';

  static Map<String, WidgetBuilder> routes = {
    authScreen: (context) => const AuthScreen(),
    categoriesScreen: (context) => const CategoriesScreen(),
    homeScreen: (context) => const HomeScreen(),
    searchScreen: (context) => const SearchScreen(),
    contentDetailScreen: (context) => const ContentDetailScreen(),
    profileScreen: (context) => const ProfileScreen(),
    // TODO: Add your other routes here
  };
}
