import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final emailController = TextEditingController();

  ForgotPasswordScreen({super.key});

  void sendOtp(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email hợp lệ")),
      );
      return;
    }

    final result = await AuthService().sendPasswordResetEmail(email);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã gửi email đặt lại mật khẩu!")),
      );
      Navigator.pop(context); // Quay lại màn hình đăng nhập
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không gửi được email. Vui lòng thử lại!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quên mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Nhập email để nhận mã xác thực (OTP)",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => sendOtp(context),
              child: const Text("Gửi mã OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
