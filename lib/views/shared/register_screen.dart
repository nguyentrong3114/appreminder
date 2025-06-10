import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/views/shared/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Register form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "REGISTER",
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
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      enabledBorder: const UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Confirm Password"),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      enabledBorder: const UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Register button
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
                          final confirmPassword = confirmPasswordController.text.trim();

                          if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                            );
                            return;
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email không hợp lệ')),
                            );
                            return;
                          }
                          if (password.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mật khẩu phải từ 6 ký tự trở lên')),
                            );
                            return;
                          }
                          if (password != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
                            );
                            return;
                          }

                          try {
                            final user = await _authService.signUpWithEmail(email, password);
                            if (user != null) {
                              await user.sendEmailVerification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đăng ký thành công! Vui lòng kiểm tra email để kích hoạt tài khoản.')),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đăng ký thất bại. Vui lòng thử lại.')),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String message = 'Đăng ký thất bại';
                            if (e.code == 'email-already-in-use') {
                              message = 'Email này đã được đăng ký. Vui lòng dùng email khác.';
                            } else if (e.code == 'invalid-email') {
                              message = 'Email không hợp lệ.';
                            } else if (e.code == 'weak-password') {
                              message = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại sau')),
                            );
                          }
                        },
                        child: const Text(
                          "REGISTER",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Navigate to login
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Already have an account? Sign In",
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
