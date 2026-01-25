import 'dart:ui';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;

  // Controllers (React useState equivalent)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // 🔴 Error snackbar (React toast equivalent)
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF16A34A), // success green
      behavior: SnackBarBehavior.floating,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 380,
            child: Column(
              children: [
                // Logo + Title
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/Logo_2 copy.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Partner Tracker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Track expenses together',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Glass Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            indicatorColor: const Color(0xFF6366F1),
                            labelColor: Colors.white,
                            unselectedLabelColor:
                                Colors.white.withOpacity(0.6),
                            tabs: const [
                              Tab(text: 'Login'),
                              Tab(text: 'Sign Up'),
                            ],
                          ),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(child: _loginForm()),
                                SingleChildScrollView(child: _signupForm()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- LOGIN FORM ----------------

  Widget _loginForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Email'),
          _input(
            controller: emailController,
            icon: Icons.mail_outline,
            hint: 'you@example.com',
          ),
          const SizedBox(height: 16),
          _label('Password'),
          _input(
            controller: passwordController,
            icon: Icons.lock_outline,
            hint: '••••••••',
            obscure: true,
          ),
          const SizedBox(height: 24),
          _primaryButton('Login'),
        ],
      ),
    );
  }

  // ---------------- SIGNUP FORM ----------------

  Widget _signupForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Name'),
          _input(
            controller: nameController,
            hint: 'Your name',
          ),
          const SizedBox(height: 16),
          _label('Email'),
          _input(
            controller: emailController,
            icon: Icons.mail_outline,
            hint: 'you@example.com',
          ),
          const SizedBox(height: 16),
          _label('Password'),
          _input(
            controller: passwordController,
            icon: Icons.lock_outline,
            hint: '••••••••',
            obscure: true,
          ),
          const SizedBox(height: 24),
          _primaryButton('Create Account'),
        ],
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    IconData? icon,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.white54, size: 18)
            : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _primaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          disabledBackgroundColor:
              const Color(0xFF6366F1).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading
            ? null
            : () async {
                // 🔹 VALIDATION (Step 13)
                if (_tabController.index == 0) {
                  // Login
                  if (emailController.text.trim().isEmpty ||
                      passwordController.text.trim().isEmpty) {
                    _showError('Please fill in all fields');
                    return;
                  }
                } else {
                  // Sign Up
                  if (nameController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty ||
                      passwordController.text.trim().isEmpty) {
                    _showError('Please fill in all fields');
                    return;
                  }
                }

                setState(() => isLoading = true);
                await Future.delayed(const Duration(milliseconds: 500));
                setState(() => isLoading = false);

_showSuccess(
  _tabController.index == 0
      ? 'Welcome back!'
      : 'Account created successfully!',
);

Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const HomeScreen()),
);

              },
        child: isLoading
            ? const Text(
                'Please wait...',
                style: TextStyle(fontSize: 14),
              )
            : Text(text),
      ),
    );
  }
}
