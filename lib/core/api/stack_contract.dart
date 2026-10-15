// Shared wire vocabulary. Keep identical across the three Flutter clients.
// Presentation aliases and endpoint-specific payment/offer/laundry adapters stay separate.
enum OrderStatus {
  notPaid,
  pending,
  confirmed,
  inProgress,
  completed,
  canceled;

  String get wireValue => name;
  static OrderStatus? fromWire(String value) {
    for (final status in values) {
      if (status.wireValue == value) return status;
    }
    return null;
  }
}

enum ServiceType {
  houseCleaning,
  carWash,
  upholsteryCleaning,
  deepCleaning,
  laundry;

  String get wireValue => name;
  static ServiceType? fromWire(String value) {
    for (final type in values) {
      if (type.wireValue == value) return type;
    }
    return null;
  }
}
