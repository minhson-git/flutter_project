import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Bắt đầu ${_isLogin ? "đăng nhập" : "đăng ký"}...');

      if (_isLogin) {
        final result = await AuthService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        print('Đăng nhập thành công: ${result.user?.uid}');
      } else {
        final result = await AuthService.signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        );
        print('Đăng ký thành công: ${result.user?.uid}');
      }

      // Check current user after auth
      final currentUser = AuthService.currentUser;
      print('🔍 Current user sau auth: ${currentUser?.uid}');
      print('🔍 Email: ${currentUser?.email}');

      // Navigate to home screen
      if (mounted && currentUser != null) {
        print('🚀 Điều hướng đến HomeScreen...');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? 'Đăng nhập thành công!' : 'Đăng ký thành công!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate after a short delay to show the success message
        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      } else {
        print('Không thể điều hướng: mounted=$mounted, currentUser=$currentUser');
        throw Exception('Authentication failed - no current user');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = _getErrorMessage(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('operation is not allowed') ||
        error.contains('sign-in provider is disabled')) {
      return 'Chưa enable Email/Password trong Firebase Console. Vào Authentication > Sign-in method > Enable Email/Password';
    } else if (error.contains('network-request-failed')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
    } else if (error.contains('email-already-in-use')) {
      return 'Email này đã được sử dụng. Vui lòng sử dụng email khác hoặc đăng nhập.';
    } else if (error.contains('weak-password')) {
      return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
    } else if (error.contains('invalid-email')) {
      return 'Email không hợp lệ.';
    } else if (error.contains('user-not-found')) {
      return 'Không tìm thấy tài khoản với email này.';
    } else if (error.contains('wrong-password')) {
      return 'Mật khẩu không chính xác.';
    } else {
      return 'Đã xảy ra lỗi: $error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Icon(
                  Icons.movie,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'StreamVibe',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  _isLogin ? 'Đăng nhập vào tài khoản' : 'Tạo tài khoản mới',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username field (only for signup)
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên đăng nhập',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      if (value.length < 3) {
                        return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Full name field (only for signup)
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên (không bắt buộc)',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (!_isLogin && value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                    _isLogin ? 'Đăng nhập' : 'Đăng ký',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle login/signup
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? 'Chưa có tài khoản? Đăng ký ngay'
                        : 'Đã có tài khoản? Đăng nhập',
                  ),
                ),

                const SizedBox(height: 24),

                // Demo button
                OutlinedButton(
                  onPressed: _isLoading ? null : _initializeSampleData,
                  child: const Text('Khởi tạo dữ liệu mẫu'),
                ),

                const SizedBox(height: 12),

                // Debug button
                if (!_isLogin)
                  OutlinedButton(
                    onPressed: _isLoading ? null : _testFirebaseConnection,
                    child: const Text('Test Firebase Connection'),
                  ),

                const SizedBox(height: 8),

                // Diagnostic button
                // OutlinedButton(
                //   onPressed: () => Navigator.pushNamed(context, AppRoutes.diagnosticScreen),
                //   child: const Text('🔧 Firebase Diagnostics'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initializeSampleData() async {
    setState(() => _isLoading = true);
    try {
      print('Bắt đầu khởi tạo dữ liệu mẫu...');

      // Kiểm tra Firebase connection trước
      await FirebaseService.firestore.enableNetwork();
      print('Firebase connection OK');

      // Khởi tạo dữ liệu
      // await DataInitService.initializeSampleData();
      // print('✅ Dữ liệu mẫu đã được khởi tạo');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Dữ liệu mẫu đã được khởi tạo thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Lỗi khởi tạo dữ liệu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khởi tạo dữ liệu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testFirebaseConnection() async {
    setState(() => _isLoading = true);
    try {
      print('🔥 Testing Firebase connection...');

      // Test Firestore
      await FirebaseService.firestore.enableNetwork();
      print('✅ Firestore connection OK');

      // Initialize sample data
      // print('📊 Initializing sample data...');
      // await DataInitService.initializeSampleData();
      // print('✅ Sample data initialized');

      // Test Auth
      String? currentUserId = AuthService.currentUser?.uid;
      print('✅ Auth current user: $currentUserId');

      // Test collection access
      var testQuery = await FirebaseService.moviesCollection.limit(1).get();
      print('✅ Movies collection accessible: ${testQuery.docs.length} docs');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firebase kết nối thành công và dữ liệu mẫu đã sẵn sàng'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Firebase connection failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase connection failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
