import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _changePassword() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: _oldPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPasswordController.text.trim());
      setState(() {
        _message = 'Đổi mật khẩu thành công!';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message ?? 'Có lỗi xảy ra.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi mật khẩu'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu cũ',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) => value == null || value.isEmpty ? 'Nhập mật khẩu cũ' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) => value == null || value.length < 6 ? 'Mật khẩu mới tối thiểu 6 ký tự' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) => value != _newPasswordController.text ? 'Mật khẩu xác nhận không khớp' : null,
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!, style: TextStyle(color: _message == 'Đổi mật khẩu thành công!' ? Colors.green : Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    _changePassword();
                  }
                },
          child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Đổi mật khẩu'),
        ),
      ],
    );
  }
}
