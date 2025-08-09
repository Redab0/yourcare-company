class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // in seconds
  final int refreshExpiresIn; // in seconds
  final String tokenType;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.tokenType,
  });

  // Convert JSON to TokenResponse
  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      refreshExpiresIn: json['refresh_expires_in'],
      tokenType: json['token_type'],
    );
  }

  // Convert TokenResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'refresh_expires_in': refreshExpiresIn,
      'token_type': tokenType,
    };
  }
}