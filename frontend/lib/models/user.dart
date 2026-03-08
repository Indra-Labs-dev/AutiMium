/// Represents a user in the system
class User {
  final String username;
  final bool disabled;

  User({
    required this.username,
    this.disabled = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      disabled: json['disabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'disabled': disabled,
    };
  }
}

/// Represents JWT authentication token
class AuthToken {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  AuthToken({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.expiresIn,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      expiresIn: json['expires_in'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}
