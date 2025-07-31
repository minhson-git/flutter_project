import 'package:flutter/material.dart';
import 'package:flutter_project/presentation/categories_screen/categories_screen.dart';
import '../presentation/auth_screen/auth_screen.dart';
import '../presentation/content_detail_screen/content_detail_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/search_screen/search_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String homeScreen = '/home-screen';
  static const String authScreen = '/auth-screen';
  static const String categoriesScreen = '/categories-screen';
  static const String searchScreen = '/search-screen';
  static const String contentDetailScreen = '/content-detail-screen';
  static const String profileScreen = '/profile-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    authScreen: (context) => const AuthScreen(),
    homeScreen: (context) => const HomeScreen(),
    categoriesScreen: (context) => const CategoriesScreen(),
    searchScreen: (context) => const SearchScreen(),
    contentDetailScreen: (context) => const ContentDetailScreen(),
    profileScreen: (context) => const ProfileScreen(),
    // TODO: Add your other routes here
  };
}
