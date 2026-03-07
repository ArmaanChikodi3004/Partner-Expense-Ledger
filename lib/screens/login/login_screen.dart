// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../home/home_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   bool isLoading = false;
//   bool _obscurePassword = true;

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     nameController.dispose();
//     super.dispose();
//   }

//   // ---------------- FEEDBACK ----------------
//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFFDC2626),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFF16A34A),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   // ---------------- LOGIN ----------------
//   Future<void> _login() async {
//     try {
//       setState(() => isLoading = true);

//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       if (!mounted) return;

//       _showSuccess('Welcome back!');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Login failed');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   // ---------------- FORGOT PASSWORD ----------------
//   Future<void> _forgotPassword() async {
//     if (emailController.text.trim().isEmpty) {
//       _showError("Please enter your email first");
//       return;
//     }

//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(
//         email: emailController.text.trim(),
//       );

//       _showSuccess("Password reset email sent!");
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? "Something went wrong");
//     }
//   }

//   // ---------------- SIGN UP ----------------
//   Future<void> _signup() async {
//     try {
//       setState(() => isLoading = true);

//       final userCredential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       final uid = userCredential.user!.uid;

//       await FirebaseFirestore.instance.collection('users').doc(uid).set({
//         'name': nameController.text.trim(),
//         'email': emailController.text.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       const partnerId = 'SpPtxpqYGsi91opBOF7W';

//       await FirebaseFirestore.instance
//           .collection('partners')
//           .doc(partnerId)
//           .update({
//         'members': FieldValue.arrayUnion([uid]),
//       });

//       if (!mounted) return;

//       _showSuccess('Account created successfully!');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Signup failed');
//     } catch (e) {
//       _showError('Something went wrong');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B0E1A),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: SizedBox(
//             width: 380,
//             child: Column(
//               children: [
//                 Column(
//                   children: [
//                     Container(
//                       width: 64,
//                       height: 64,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF6366F1).withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       alignment: Alignment.center,
//                       child: Image.asset(
//                         'assets/Logo_2 copy.png',
//                         width: 32,
//                         height: 32,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Partner Ledger',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       'Track expenses together',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF9CA3AF),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(24),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF111827).withOpacity(0.6),
//                         borderRadius: BorderRadius.circular(24),
//                         border:
//                             Border.all(color: Colors.white.withOpacity(0.1)),
//                       ),
//                       child: Column(
//                         children: [
//                           TabBar(
//                             controller: _tabController,
//                             indicatorColor: const Color(0xFF6366F1),
//                             labelColor: Colors.white,
//                             unselectedLabelColor:
//                                 Colors.white.withOpacity(0.6),
//                             tabs: const [
//                               Tab(text: 'Login'),
//                               Tab(text: 'Sign Up'),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 420,
//                             child: TabBarView(
//                               controller: _tabController,
//                               children: [
//                                 _loginForm(),
//                                 _signupForm(),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------- FORMS ----------------
//   Widget _loginForm() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _label('Email'),
//           _input(controller: emailController, hint: 'you@example.com'),
//           const SizedBox(height: 16),
//           _label('Password'),
//           _input(
//             controller: passwordController,
//             hint: '••••••••',
//             obscure: true,
//           ),
//           const SizedBox(height: 8),

//           // 🔥 FORGOT PASSWORD BUTTON
//           Align(
//             alignment: Alignment.centerRight,
//             child: TextButton(
//               onPressed: _forgotPassword,
//               child: const Text(
//                 "Forgot Password?",
//                 style: TextStyle(
//                   color: Color(0xFF6366F1),
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),
//           _primaryButton('Login'),
//         ],
//       ),
//     );
//   }

//   Widget _signupForm() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _label('Name'),
//           _input(controller: nameController, hint: 'Your name'),
//           const SizedBox(height: 16),
//           _label('Email'),
//           _input(controller: emailController, hint: 'you@example.com'),
//           const SizedBox(height: 16),
//           _label('Password'),
//           _input(
//             controller: passwordController,
//             hint: '••••••••',
//             obscure: true,
//           ),
//           const SizedBox(height: 28),
//           _primaryButton('Create Account'),
//         ],
//       ),
//     );
//   }

//   // ---------------- COMPONENTS ----------------
//   Widget _label(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 13, color: Colors.white70),
//       ),
//     );
//   }

//   Widget _input({
//     required TextEditingController controller,
//     required String hint,
//     bool obscure = false,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure ? _obscurePassword : false,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.white38),
//         filled: true,
//         fillColor: const Color(0xFF1F2937),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         suffixIcon: obscure
//             ? IconButton(
//                 icon: Icon(
//                   _obscurePassword
//                       ? Icons.visibility_off
//                       : Icons.visibility,
//                   color: Colors.white54,
//                   size: 20,
//                 ),
//                 onPressed: () {
//                   setState(() => _obscurePassword = !_obscurePassword);
//                 },
//               )
//             : null,
//       ),
//     );
//   }

//   Widget _primaryButton(String text) {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: ElevatedButton(
//         onPressed: isLoading
//             ? null
//             : () {
//                 _tabController.index == 0 ? _login() : _signup();
//               },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF6366F1),
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 0,
//         ),
//         child: isLoading
//             ? const Text('Please wait...')
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     text,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     width: 28,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.arrow_forward,
//                       size: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }



import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

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
  bool _obscurePassword = true;

  OverlayEntry? _loadingOverlay;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // ---------------- LOADING OVERLAY ----------------

  void _showLoading() {
    final overlay = Overlay.of(context);

    _loadingOverlay = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/animations/login_loading.json',
                      width: 120,
                      repeat: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Please wait...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_loadingOverlay!);
  }

  void _hideLoading() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  // ---------------- FEEDBACK ----------------

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------- LOGIN ----------------

  Future<void> _login() async {
    try {
      setState(() => isLoading = true);
      _showLoading();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _hideLoading();

      if (!mounted) return;

      _showSuccess('Welcome back!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _hideLoading();
      _showError(e.message ?? 'Login failed');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ---------------- FORGOT PASSWORD ----------------

  Future<void> _forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      _showError("Please enter your email first");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      _showSuccess("Password reset email sent!");
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Something went wrong");
    }
  }

  // ---------------- UI ----------------

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
                      'Partner Ledger',
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

                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            indicatorColor: const Color(0xFF6366F1),
                            labelColor: Colors.white,
                            tabs: const [
                              Tab(text: 'Login'),
                            ],
                          ),
                          SizedBox(
                            height: 360,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _loginForm(),
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
          _input(controller: emailController, hint: 'you@example.com'),
          const SizedBox(height: 16),
          _label('Password'),
          _input(
            controller: passwordController,
            hint: '••••••••',
            obscure: true,
          ),

          const SizedBox(height: 8),

          // ✅ FORGOT PASSWORD BUTTON ADDED
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          _primaryButton('Login'),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.white70),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure ? _obscurePassword : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
      ),
    );
  }

  Widget _primaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const Text('Please wait...')
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
