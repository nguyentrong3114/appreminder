import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String email;
  final otpController = TextEditingController();

  OtpVerificationScreen({required this.email});

  void verifyOtp(BuildContext context) {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập mã OTP gồm 6 chữ số")),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Xác minh thành công!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Xác minh OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("Đã gửi mã xác minh đến $email"),
            SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: "Nhập mã OTP",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => verifyOtp(context),
              child: Text("Xác minh"),
            ),
          ],
        ),
      ),
    );
  }
}
