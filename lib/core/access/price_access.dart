import 'package:flutter/foundation.dart';
import '../../data/models/auth/login_response.dart';

/// Presentation authority is independent of token rotation. Unresolved access
/// is denied; only current-user server responses may change a resolved grant.
class PriceAccess extends ChangeNotifier {
  PriceAccess();
  static final instance = PriceAccess();
  User? _user;
  bool _forcedDenied = false;
  int _epoch = 0;
  int _accountGeneration = -1;
  bool get resolved => _user != null;
  bool get allowed => !_forcedDenied && _user?.effectiveCanSeePrices == true;
  bool get canManage => !_forcedDenied && _user?.canManagePriceAccess == true;
  int get epoch => _epoch;
  String? get userId => _user?.id;

  void reset({int? generation}) {
    _accountGeneration = generation ?? -1;
    _user = null;
    _forcedDenied = false;
    _epoch++;
    notifyListeners();
  }

  void publish(User user,
      {required int generation, bool pricesHidden = false}) {
    if (generation < _accountGeneration) return;
    final previousAllowed = allowed;
    final previousManage = canManage;
    final changed = _accountGeneration != generation ||
        _user?.id != user.id ||
        _forcedDenied != pricesHidden ||
        previousAllowed != (!pricesHidden && user.effectiveCanSeePrices) ||
        previousManage != (!pricesHidden && user.canManagePriceAccess);
    _accountGeneration = generation;
    _user = user;
    _forcedDenied = pricesHidden;
    if (changed) {
      _epoch++;
      notifyListeners();
    }
  }

  void deny() {
    if (_forcedDenied) return;
    _forcedDenied = true;
    _epoch++;
    notifyListeners();
  }
}
