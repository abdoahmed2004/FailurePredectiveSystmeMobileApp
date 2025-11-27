// A wrapper to hold the full response (token + user data + message)
class AuthResponse {
  final String token;
  final User user;
  final String message;

  AuthResponse({required this.token, required this.user, required this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user']),
      message: json['message'] ?? 'Operation successful',
    );
  }
}

// The core User model, including the isVerified field
class User {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isVerified; 

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? 'unknown_id', 
      fullName: json['fullName'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      role: json['role'] ?? 'engineer',
      isVerified: json['isVerified'] ?? false, 
    );
  }
}