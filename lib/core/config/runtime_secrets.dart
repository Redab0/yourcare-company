class RuntimeSecrets {
  RuntimeSecrets._();

  static const String mapsApiKey = String.fromEnvironment('MAPS_API_KEY');

  static String requireMapsApiKey() {
    assert(
      mapsApiKey.isNotEmpty,
      'Missing --dart-define=MAPS_API_KEY',
    );
    if (mapsApiKey.isEmpty) {
      throw StateError('Missing required MAPS_API_KEY dart-define.');
    }
    return mapsApiKey;
  }
}
