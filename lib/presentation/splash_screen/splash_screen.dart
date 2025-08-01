import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/data_init_service.dart';
import '../../services/firebase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _loadingFadeAnimation;

  bool _showLoading = false;
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const int _splashDuration = 3000; // 3 seconds
  static const int _timeoutDuration = 5000; // 5 seconds

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
    _setSystemUIOverlay();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Loading fade animation
    _loadingFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeIn,
    ));
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0A0A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _startSplashSequence() async {
    // Start logo animation
    _logoAnimationController.forward();

    // Show loading indicator after logo animation
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _showLoading = true;
      });
      _loadingAnimationController.forward();
    }

    // Perform background initialization
    await _performBackgroundTasks();
  }

  Future<void> _performBackgroundTasks() async {
    try {
      // Firebase và dữ liệu mẫu
      print('Initialize Firebase and data...');
      await FirebaseService.firestore.enableNetwork();
      await DataInitService.initializeSampleData();
      // print('Firebase và dữ liệu sẵn sàng');

      // Simulate background tasks with timeout
      await Future.wait([
        _checkAuthenticationStatus(),
        _loadUserPreferences(),
        _fetchContentCategories(),
        _prepareCachedThumbnails(),
      ]).timeout(
        const Duration(milliseconds: _timeoutDuration),
        onTimeout: () {
          throw Exception('Initialization timeout');
        },
      );

      // Wait for minimum splash duration
      await Future.delayed(const Duration(milliseconds: _splashDuration));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      print('Background tasks error: $e');
      if (mounted) {
        _handleError();
      }
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    // Simulate authentication check
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _loadUserPreferences() async {
    // Simulate loading user preferences
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _fetchContentCategories() async {
    // Simulate fetching content categories
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  Future<void> _prepareCachedThumbnails() async {
    // Simulate preparing cached thumbnails
    await Future.delayed(const Duration(milliseconds: 700));
  }

  void _handleError() {
    setState(() {
      _hasError = true;
    });

    if (_retryCount < _maxRetries) {
      // Auto retry after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _retryInitialization();
        }
      });
    }
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _retryCount++;
    });
    _performBackgroundTasks();
  }

  void _navigateToNextScreen() {
    // Check Firebase Auth state
    User? currentUser = AuthService.currentUser;

    print('SplashScreen - Current User: ${currentUser?.uid}');
    print('SplashScreen - Email: ${currentUser?.email}');

    String nextRoute;
    if (currentUser != null) {
      print('User is logged in, navigate to HomeScreen');
      nextRoute = AppRoutes.homeScreen;
    } else {
      print('Not logged in, navigate to AuthScreen');
      nextRoute = AppRoutes.authScreen;
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.scaffoldBackgroundColor,
              AppTheme.lightTheme.colorScheme.surface,
              AppTheme.lightTheme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      AnimatedBuilder(
                        animation: _logoAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Opacity(
                              opacity: _logoFadeAnimation.value,
                              child: _buildLogo(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 8.h),

                      // App Name
                      AnimatedBuilder(
                        animation: _logoAnimationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: Text(
                              'Cinemate',
                              style: AppTheme.lightTheme.textTheme.headlineLarge
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Tagline
                      AnimatedBuilder(
                        animation: _logoAnimationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoFadeAnimation.value * 0.8,
                            child: Text(
                              'Your Ultimate Streaming Experience',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Loading Section
                SizedBox(
                  height: 12.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_showLoading && !_hasError) ...[
                        AnimatedBuilder(
                          animation: _loadingAnimationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _loadingFadeAnimation.value,
                              child: _buildLoadingIndicator(),
                            );
                          },
                        ),
                        SizedBox(height: 2.h),
                        AnimatedBuilder(
                          animation: _loadingAnimationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _loadingFadeAnimation.value,
                              child: Text(
                                'Loading your content...',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      if (_hasError) ...[
                        _buildErrorSection(),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'play_arrow',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 12.w,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 8.w,
      height: 8.w,
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppTheme.lightTheme.colorScheme.primary,
        ),
        backgroundColor:
        AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildErrorSection() {
    return Column(
      children: [
        CustomIconWidget(
          iconName: 'error_outline',
          color: AppTheme.lightTheme.colorScheme.error,
          size: 8.w,
        ),
        SizedBox(height: 1.h),
        Text(
          'Connection Error',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          _retryCount < _maxRetries
              ? 'Retrying... (${_retryCount + 1}/$_maxRetries)'
              : 'Please check your connection',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        if (_retryCount >= _maxRetries) ...[
          SizedBox(height: 2.h),
          TextButton(
            onPressed: () {
              setState(() {
                _retryCount = 0;
                _hasError = false;
              });
              _performBackgroundTasks();
            },
            child: Text(
              'Retry',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
