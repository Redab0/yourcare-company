# Flutter Apps Token Handling Fixes

## For Customer App

### 1. Update TokenResponse Model

```dart
// In lib/data/models/auth/token_response.dart
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int refreshExpiresIn;
  final String tokenType;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.tokenType,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      refreshExpiresIn: json['refresh_expires_in'],
      tokenType: json['token_type'],
    );
  }
}
```

### 2. Update Token Storage Logic

```dart
// In auth_repository.dart or equivalent
// Replace the existing token parsing and saving code:

// Make login request
final response = await _authApiClient.login(
  email: email,
  password: password,
  deviceId: deviceId,
  deviceMetadata: deviceMetadata,
);

// Parse tokens
final tokensData = response.data['tokens'];
final tokenResponse = TokenResponse.fromJson(tokensData);

// Calculate expiry times from seconds
final accessTokenExpiry = DateTime.now().add(Duration(seconds: tokenResponse.expiresIn));
final refreshTokenExpiry = DateTime.now().add(Duration(seconds: tokenResponse.refreshExpiresIn));

// Save tokens with their expiry
await _tokenStorage.saveAccessToken(tokenResponse.accessToken, accessTokenExpiry);
await _tokenStorage.saveRefreshToken(tokenResponse.refreshToken, refreshTokenExpiry);
```

### 3. Fix Token Refresh Function

```dart
// In token_refresh_manager.dart or equivalent
// Update the token refresh parsing code:

final response = await _authApiClient.refreshToken(
  refreshToken: refreshToken!,
  deviceId: deviceId,
);

// Parse new tokens
final accessToken = response.data['access_token'];
final newRefreshToken = response.data['refresh_token'];
final expiresIn = response.data['expires_in'];
final refreshExpiresIn = response.data['refresh_expires_in'];

// Calculate expiry times
final accessTokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
final refreshTokenExpiry = DateTime.now().add(Duration(seconds: refreshExpiresIn));

// Save tokens
await _tokenStorage.saveAccessToken(accessToken, accessTokenExpiry);
await _tokenStorage.saveRefreshToken(newRefreshToken, refreshTokenExpiry);
```

## For Driver App

### 1. Update TokenResponse Class

```dart
// In lib/data/models/auth/token_response.dart
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int refreshExpiresIn; 
  final String tokenType;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.tokenType,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      refreshExpiresIn: json['refresh_expires_in'],
      tokenType: json['token_type'],
    );
  }
}
```

### 2. Update Token Storage Method

```dart
// In lib/core/services/auth_service.dart
// Update the _saveTokens method:

// Save tokens to secure storage
Future<void> _saveTokens(TokenResponse tokenResponse) async {
  await _secureStorage.saveAccessToken(tokenResponse.accessToken);
  await _secureStorage.saveRefreshToken(tokenResponse.refreshToken);
  
  // Calculate and save expiry times
  final accessTokenExpiry = DateTime.now().add(
    Duration(seconds: tokenResponse.expiresIn),
  );
  final refreshTokenExpiry = DateTime.now().add(
    Duration(seconds: tokenResponse.refreshExpiresIn),
  );
  
  await _secureStorage.saveTokenExpiry(accessTokenExpiry);
  await _secureStorage.saveRefreshTokenExpiry(refreshTokenExpiry);
}
```

### 3. Update Refresh Token Function

```dart
// In lib/core/services/api_client.dart
// Update the _refreshToken method:

Future<bool> _refreshToken() async {
  try {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return false;
    
    // Create a new dio instance without auth interceptor to avoid loops
    final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
    
    final response = await refreshDio.post(
      '/api/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    
    if (response.statusCode == 200) {
      // Save the new tokens
      final accessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];
      final expiresIn = response.data['expires_in'] as int;
      final refreshExpiresIn = response.data['refresh_expires_in'] as int;
      
      // Calculate expiry times
      final accessTokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
      final refreshTokenExpiry = DateTime.now().add(Duration(seconds: refreshExpiresIn));
      
      // Save tokens and their expiry
      await _secureStorage.saveAccessToken(accessToken);
      await _secureStorage.saveRefreshToken(newRefreshToken);
      await _secureStorage.saveTokenExpiry(accessTokenExpiry);
      await _secureStorage.saveRefreshTokenExpiry(refreshTokenExpiry);
      
      return true;
    }
    
    return false;
  } catch (e) {
    // If refresh fails, clear tokens and force re-login
    await _secureStorage.clearAuthData();
    return false;
  }
}
```

## Important Note

Make sure both apps properly handle the nested "tokens" object in the response. The backend now returns the token information in a nested object structure like:

```json
{
  "user": { ... },
  "tokens": {
    "access_token": "...",
    "refresh_token": "...",
    "token_type": "Bearer",
    "expires_in": 1800,
    "refresh_expires_in": 31536000
  }
}
```

Adjust the parsing code accordingly to handle this structure correctly.