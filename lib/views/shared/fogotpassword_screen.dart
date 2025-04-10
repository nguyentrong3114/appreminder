import 'package:flutter/material.dart';
import 'package:flutter_app/views/shared/otp_screen.dart';


class ForgotPasswordScreen extends StatelessWidget {
  final emailController = TextEditingController();

  void sendOtp(BuildContext context) {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập email hợp lệ")),
      );
      return;
    }


    print("Đã gửi OTP đến $email");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quên mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "Nhập email để nhận mã xác thực (OTP)",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => sendOtp(context),
              child: Text("Gửi mã OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
