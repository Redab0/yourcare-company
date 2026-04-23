enum UserRole {
  businessOwner('business_owner'),
  manager('manager'),
  worker('worker'),
  driver('driver');

  final String value;
  const UserRole(this.value);
}

extension UserRoleX on UserRole {
  static UserRole? fromValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    for (final role in UserRole.values) {
      if (role.value == raw) return role;
    }
    return null;
  }
}
