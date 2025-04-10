class User {
  String name;
  String email;
  String token;

  User({
    required this.name,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      token: json['token'],
    );
  }

  @override
  String toString() {
    return 'User: $name, Email: $email, Token: $token';
  }
}
