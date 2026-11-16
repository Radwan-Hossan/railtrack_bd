enum UserRole {
  passenger,
  driver,
  admin,
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = UserRole.passenger,
  });

  bool get isAdmin => role == UserRole.admin;
}
