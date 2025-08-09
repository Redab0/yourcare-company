class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiry;
  final DateTime refreshTokenExpiry;
  final String tokenType;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry,
    required this.tokenType,
  });

  // Create tokens from JSON response
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    // Handle both formats - seconds-based expiry or direct ISO datetime strings
    DateTime accessTokenExpiry;
    DateTime refreshTokenExpiry;
    
    // Get tokens with fallbacks for missing values
    final accessToken = json['access_token'] ?? '';
    if (accessToken.isEmpty) {
      print('Warning: Empty access token received');
    }
    
    final refreshToken = json['refresh_token'] ?? '';
    if (refreshToken.isEmpty) {
      print('Warning: Empty refresh token received');
    }
    
    // For mock tokens, use long expiry times
    if (accessToken.toString().startsWith('mock_')) {
      final now = DateTime.now();
      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiry: now.add(const Duration(days: 30)), // Long expiry for mock
        refreshTokenExpiry: now.add(const Duration(days: 60)), // Long expiry for mock
        tokenType: json['token_type'] ?? 'Bearer',
      );
    }
    
    if (json.containsKey('expires_in')) {
      // Backend sends token information in seconds
      final int expiresIn = json['expires_in'] is String 
          ? int.parse(json['expires_in']) 
          : json['expires_in'];
          
      final int refreshExpiresIn = json['refresh_expires_in'] is String 
          ? int.parse(json['refresh_expires_in'])
          : json['refresh_expires_in'];
      
      // Calculate expiry dates from seconds
      accessTokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
      refreshTokenExpiry = DateTime.now().add(Duration(seconds: refreshExpiresIn));
    } 
    else if (json.containsKey('access_token_expiry') && json.containsKey('refresh_token_expiry')) {
      // Direct date format (stored format)
      try {
        accessTokenExpiry = DateTime.parse(json['access_token_expiry']);
        refreshTokenExpiry = DateTime.parse(json['refresh_token_expiry']);
      } catch (e) {
        // Fallback to defaults if parsing fails
        accessTokenExpiry = DateTime.now().add(const Duration(minutes: 30));
        refreshTokenExpiry = DateTime.now().add(const Duration(days: 7));
        print('Error parsing token expiry dates: $e');
      }
    }
    else {
      // No expiry information available, set reasonable defaults
      accessTokenExpiry = DateTime.now().add(const Duration(minutes: 30));
      refreshTokenExpiry = DateTime.now().add(const Duration(days: 7));
      print('Warning: No token expiry information in response, using defaults');
    }
    
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiry: accessTokenExpiry,
      refreshTokenExpiry: refreshTokenExpiry,
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }

  // Convert tokens to JSON for storage
  Map<String, String> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expiry': accessTokenExpiry.toIso8601String(),
      'refresh_token_expiry': refreshTokenExpiry.toIso8601String(),
      'token_type': tokenType,
    };
  }

  // Check if access token is expired or about to expire (within 1 minute)
  bool get isAccessTokenExpired {
    // When using mock API, tokens never expire
    if (accessToken.startsWith('mock_')) {
      return false;
    }
    final now = DateTime.now();
    return now.isAfter(accessTokenExpiry.subtract(const Duration(minutes: 1)));
  }

  // Check if refresh token is expired
  bool get isRefreshTokenExpired {
    // When using mock API, tokens never expire
    if (refreshToken.startsWith('mock_')) {
      return false;
    }
    return DateTime.now().isAfter(refreshTokenExpiry);
  }
}