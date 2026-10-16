import '../../data/models/auth/login_response.dart';

/// One secure-storage value commits credentials, identity and retry recovery.
class SessionCredentials {
  static final jwtPattern =
      RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]{43}$');
  static final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
  static const providerRoles = {
    'business_owner',
    'manager',
    'worker',
    'driver'
  };
  const SessionCredentials({
    required this.token,
    this.user,
    this.refreshToken,
    this.accessExpiresAt,
    this.sessionId,
    this.requestId,
    this.requestCredential,
    this.requestIsRefresh = false,
  });

  final String token;
  final User? user;
  final String? refreshToken;
  final DateTime? accessExpiresAt;
  final String? sessionId;
  final String? requestId;
  final String? requestCredential;
  final bool requestIsRefresh;

  void validateReplacement(SessionCredentials previous, DateTime now) {
    if (token.length > 16384 ||
        !jwtPattern.hasMatch(token) ||
        user?.id == null ||
        !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(user!.id!) ||
        !providerRoles.contains(user!.role) ||
        user!.enabled == false ||
        refreshToken == null ||
        refreshToken!.isEmpty ||
        refreshToken!.length > 16384 ||
        refreshToken!.contains(RegExp(r'[\x00-\x20\x7f]')) ||
        sessionId == null ||
        !uuidPattern.hasMatch(sessionId!) ||
        accessExpiresAt == null ||
        !accessExpiresAt!.isAfter(now) ||
        accessExpiresAt!
            .isAfter(now.add(const Duration(hours: 1, seconds: 60))) ||
        (previous.user?.id != null && previous.user!.id != user!.id) ||
        (previous.refreshToken != null && previous.sessionId != sessionId)) {
      throw const FormatException('Invalid renewed session.');
    }
  }

  SessionCredentials withRecovery(String id) => SessionCredentials(
        token: token,
        user: user,
        refreshToken: refreshToken,
        accessExpiresAt: accessExpiresAt,
        sessionId: sessionId,
        requestId: id,
        requestCredential: refreshToken ?? token,
        requestIsRefresh: refreshToken != null,
      );

  SessionCredentials withUser(User value) => SessionCredentials(
        token: token,
        user: value,
        refreshToken: refreshToken,
        accessExpiresAt: accessExpiresAt,
        sessionId: sessionId,
        requestId: requestId,
        requestCredential: requestCredential,
        requestIsRefresh: requestIsRefresh,
      );

  Map<String, dynamic> toJson() => {
        'version': 2,
        'token': token,
        'user': user?.toJson(),
        'refreshToken': refreshToken,
        'accessExpiresAt': accessExpiresAt?.toUtc().toIso8601String(),
        'sessionId': sessionId,
        'requestId': requestId,
        'requestCredential': requestCredential,
        'requestIsRefresh': requestIsRefresh,
      };

  factory SessionCredentials.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 2 || json['token'] is! String) {
      throw const FormatException('Invalid stored session.');
    }
    return SessionCredentials(
      token: json['token'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      refreshToken: json['refreshToken'] as String?,
      accessExpiresAt: json['accessExpiresAt'] == null
          ? null
          : DateTime.parse(json['accessExpiresAt'] as String).toUtc(),
      sessionId: json['sessionId'] as String?,
      requestId: json['requestId'] as String?,
      requestCredential: json['requestCredential'] as String?,
      requestIsRefresh: json['requestIsRefresh'] == true,
    );
  }
}
