/// core/loading.dart
abstract interface class LoadingController {
  /// Show a blocking loader (optionally identified by [tag]).
  void show([String tag = 'global']);

  /// Hide the loader associated with [tag] (or the global one).
  void hide([String tag = 'global']);
}
