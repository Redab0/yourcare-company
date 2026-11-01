import 'package:flutter/material.dart';
import '../utils/context_extensions.dart';
import 'price_access.dart';

class PriceAccessScope extends InheritedNotifier<PriceAccess> {
  PriceAccessScope({super.key, PriceAccess? access, required super.child})
      : super(notifier: access ?? PriceAccess.instance);
  static PriceAccess of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<PriceAccessScope>()
          ?.notifier ??
      PriceAccess.instance;
}

extension PriceAccessContext on BuildContext {
  bool get canSeePrices => PriceAccessScope.of(this).allowed;
  bool get canManagePriceAccess => PriceAccessScope.of(this).canManage;
}

class PriceOnly extends StatelessWidget {
  const PriceOnly({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      context.canSeePrices ? child : const SizedBox.shrink();
}

/// Lazy construction prevents financial routes fetching or retaining data when
/// opened through a saved link without access.
class FinancialAccessGuard extends StatelessWidget {
  const FinancialAccessGuard({super.key, required this.builder});
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) => context.canSeePrices
      ? builder(context)
      : Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(context.l10n.priceAccessUnavailable)),
        );
}
