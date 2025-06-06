import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/views/shared/register_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_app/views/shared/fogotpassword_screen.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "MANAGE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "SCHEDULE",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Login form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text("Email"),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "example@email.com",
                      enabledBorder: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Password"),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.visibility_off),
                      enabledBorder: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot your password?",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // login button
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          // Kiểm tra định dạng email
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email không hợp lệ')),
                            );
                            return;
                          }
                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                            );
                            return;
                          }

                          try {
                            final user = await _authService.signInWithEmail(email, password);
                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => MainScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sai username hoặc password')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sai username hoặc password')),
                            );
                          }
                        },
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Or login with",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // social
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // fb api
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          color: Colors.red,
                          size: 28,
                        ),
                        onPressed: () async {
                          final user = await _authService.signInWithGoogle();
                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MainScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đăng nhập Google thất bại')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
