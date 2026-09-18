import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ChenoMorApp());
}

class ChenoMorApp extends StatelessWidget {
  const ChenoMorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChenoMor',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeHomeScreen(),
    );
  }
}

// Custom Text Field Helper
Widget buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: const Color(0xFF818CF8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
    ),
  );
}

// 1. Welcome / Home Screen
class WelcomeHomeScreen extends StatelessWidget {
  const WelcomeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF31103F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // লোগো ইমেজ ব্যবহার করা হলো (logo.png)
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEC4899).withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // যদি ইমেজ লোড করতে সমস্যা হয় তবে ফলব্যাক হিসেবে আইকন দেখাবে
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.bolt_rounded, size: 60, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'ChenoMor',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Where Strangers Become Familiar.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF818CF8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFEC4899)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                    },
                    child: const Text('Get Started - Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: const Text('Already have an account? Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2. Sign Up Screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  
  String selectedGender = 'Male';
  String interestedIn = 'Everyone';
  int selectedAge = 21;
  bool isLoading = false;

  final String scriptUrl = 'https://script.google.com/macros/s/AKfycbzvrJ-NYKu0-MJ01GzPlOgjGDc6URG2R93RJsf0wsluFA2pazasNwgKN9NFvdlYU_I0/exec';

  Future<void> registerUser() async {
    setState(() { isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode({
          "action": "register",
          "name": _nameController.text.trim(),
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passController.text.trim(),
          "gender": selectedGender,
          "country": "Bangladesh",
          "interestedIn": interestedIn,
          "age": selectedAge.toString(),
        }),
      );

      final resData = jsonDecode(response.body);
      if (resData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created Successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Failed!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            buildTextField(_nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 16),
            buildTextField(_usernameController, 'Username', Icons.alternate_email),
            const SizedBox(height: 16),
            buildTextField(_emailController, 'Gmail (@gmail.com)', Icons.email_outlined),
            const SizedBox(height: 16),
            buildTextField(_passController, 'Password', Icons.lock_outline, obscureText: true),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFEC4899)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                onPressed: isLoading ? null : registerUser,
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Complete Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Login Screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login', style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextField(emailController, 'Gmail / Username', Icons.person_outline),
            const SizedBox(height: 16),
            buildTextField(passController, 'Password', Icons.lock_outline, obscureText: true),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFEC4899)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                },
                child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChenoMor Dashboard'), backgroundColor: const Color(0xFF1E1B4B)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_call_rounded, size: 80, color: Color(0xFFEC4899)),
              const SizedBox(height: 20),
              const Text('Ready to meet strangers?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video Chat feature is coming up next!')),
                  );
                },
                child: const Text('Start Video Chat', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
