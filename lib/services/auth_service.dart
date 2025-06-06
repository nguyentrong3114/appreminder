import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng nhập bằng email và password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      print('Bắt đầu đăng nhập với email: $email');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Đăng nhập thành công!');
      print('User ID: ${result.user?.uid}');
      print('Email verified: ${result.user?.emailVerified}');

      return result.user;
    } catch (e) {
      print('Lỗi đăng nhập email: $e');
      return null;
    }
  }

  // Đăng nhập bằng Google
  Future<User?> signInWithGoogle() async {
    try {
      print('Bắt đầu đăng nhập Google');

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Google sign-in bị hủy');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      print('Đăng nhập Google thành công!');
      print('User ID: ${result.user?.uid}');

      return result.user;
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // Đăng ký bằng email và password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Lỗi đăng ký email: $e');
      return null;
    }
  }

  // Gửi email đặt lại mật khẩu
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Lỗi gửi email đặt lại mật khẩu: $e');
      return false;
    }
  }
}
