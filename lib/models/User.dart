class User{
    String name;
    String email;
    String password;
    User({
        required this.name,
        required this.email,
        required this.password,
    });
    @override
    String toString() {
        return 'User: $name, Email: $email, Password: $password';
    }
}