class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final String role; 

  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class RegisterAdminResponse {
  final bool success;
  final String message;
  final String ownerToken;

  RegisterAdminResponse({
    required this.success,
    required this.message,
    required this.ownerToken,
  });

  factory RegisterAdminResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return RegisterAdminResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      ownerToken: data['owner_token'] ?? '',
    );
  }
}