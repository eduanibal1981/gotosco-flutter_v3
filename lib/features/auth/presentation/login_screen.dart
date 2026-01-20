import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // State to toggle between Login and Sign Up views
  bool _isLogin = true;
  // State to toggle password visibility
  bool _isPasswordVisible = false;

  // Controllers (Mocking them for UI purposes)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // Professional Color Palette used in this screen
  final Color _primaryDark = Colors.indigo.shade900;
  final Color _primaryLight = Colors.indigo.shade500;
  final Color _bgColor = Colors.grey.shade50;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ============== GOOGLE SIGN-IN HANDLER ==============
  Future<void> _handleGoogleSignIn() async {
    final result = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();

    if (!mounted) return;

    // Web OAuth redirects, so result is null
    // The router will handle navigation after redirect
    if (result == null) return;

    _handleAuthResult(result);
  }

  // ============== EMAIL/PASSWORD HANDLER ==============
  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isLogin && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    AuthResult result;
    if (_isLogin) {
      result = await ref
          .read(authControllerProvider.notifier)
          .signInWithEmail(email, password);
    } else {
      result = await ref
          .read(authControllerProvider.notifier)
          .signUp(email: email, password: password, fullName: name);
    }

    if (!mounted) return;
    _handleAuthResult(result);
  }

  void _handleAuthResult(AuthResult result) {
    if (result.success) {
      // Check if user has a role assigned
      if (result.role == null || result.role!.isEmpty) {
        // New user without role or role not found - go to role selection
        context.go('/role-selection');
      } else {
        // Existing user with role - go to appropriate dashboard
        if (result.role == 'driver') {
          context.go('/driver-home');
        } else {
          context.go('/parent-home');
        }
      }
    } else if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_isLogin ? "Login" : "Sign up"} failed: ${result.error}',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: _bgColor,
      // Using Stack to layer the wavy background behind the content
      body: Stack(
        children: [
          // --- 1. Wavy Header Background ---
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: size.height * 0.4, // Covers top 40%
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryDark, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // --- 2. Main Content Scroll View ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // --- Header Illustration & Text ---
                    _buildHeaderSection(),

                    const SizedBox(height: 40),

                    // --- The Form Container ---
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isLogin ? 'Welcome Back' : 'Create Account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _primaryDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Fields
                            if (!_isLogin) ...[
                              _buildTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                icon: Icons.person_outline,
                                autofillHints: [AutofillHints.name],
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              autofillHints: [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleEmailAuth(),
                            ),

                            if (_isLogin) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {}, // Mock action
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: _primaryLight),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 24),
                            ],

                            // Main Action Button
                            const SizedBox(height: 8),
                            _buildMainButton(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- Social Login Section ---
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social Buttons stacked
                    _buildSocialButton(
                      label: isLoading
                          ? 'Signing in...'
                          : 'Continue with Google',
                      // Using built-in icons for UI demo. In real app use brand SVGs
                      icon: Icons.g_mobiledata,
                      color: Colors.red.shade700,
                      onTap: isLoading ? null : _handleGoogleSignIn,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 16),
                    _buildSocialButton(
                      label: 'Continue with Apple',
                      icon: Icons.apple,
                      color: Colors.black,
                      onTap: () {},
                    ),

                    const SizedBox(height: 40),

                    // --- Bottom Toggle ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? "Don't have an account?"
                              : "Already have an account?",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        TextButton(
                          onPressed: () {
                            // Animate the change between login and signup modes
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? 'Sign Up' : 'Sign In',
                            style: TextStyle(
                              color: _primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS & WIDGETS =================

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        const Text(
          'GoToSco',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? 'Safe journeys for your children.'
              : 'Join the community today.',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade500,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryLight, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildMainButton() {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [_primaryDark, _primaryLight]),
        boxShadow: [
          BoxShadow(
            color: _primaryLight.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleEmailAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _isLogin ? 'LOGIN' : 'SIGN UP',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CUSTOM CLIPPERS =================

// Creates the wavy shape at the top of the screen
class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);

    // First curve (going up)
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 50);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Second curve (going down)
    var secondControlPoint = Offset(
      size.width - (size.width / 3.25),
      size.height - 105,
    );
    var secondEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
