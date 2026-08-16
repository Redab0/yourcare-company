import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/features/screens/home/business_setup_tour_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class BusinessShowcaseInteractionLock {
  static final ValueNotifier<bool> listenable = ValueNotifier<bool>(false);
  static final Set<String> _activeScopes = <String>{};

  static bool get isLocked => listenable.value;

  static void lock(String scope) {
    if (!_activeScopes.add(scope)) return;
    if (!listenable.value) listenable.value = true;
  }

  static void unlock(String scope) {
    if (!_activeScopes.remove(scope)) return;
    if (_activeScopes.isEmpty && listenable.value) listenable.value = false;
  }
}

String? businessShowcaseOwnerId(User? user) {
  final businessId = user?.businessId?.trim();
  if (businessId?.isNotEmpty == true) return businessId;
  final userId = user?.id?.trim();
  return userId?.isNotEmpty == true ? userId : null;
}

class BusinessShowcaseTourController {
  final String scope;
  final BusinessSetupTourStorage? _storage;
  final Set<String> _scheduledJourneys = <String>{};
  late final ShowcaseView _showcaseView;

  String? _completionOwnerId;
  String? _completionJourneyId;
  bool _disposed = false;

  BusinessShowcaseTourController({
    required this.scope,
    BusinessSetupTourStorage? storage,
  }) : _storage = storage ??
            (sl.isRegistered<SharedPreferences>()
                ? BusinessSetupTourStorage(sl<SharedPreferences>())
                : null) {
    _showcaseView = ShowcaseView.register(
      scope: scope,
      enableAutoScroll: true,
      skipIfTargetNotPresent: true,
      disableBarrierInteraction: true,
      blurValue: 1,
      overlayColor: AppTheme.navy,
      overlayOpacity: 0.88,
      semanticEnable: true,
      globalFloatingActionWidget: _buildSkipButton,
      onStart: (_, __) => BusinessShowcaseInteractionLock.lock(scope),
      onFinish: _completeTour,
      onDismiss: (_) => _completeTour(),
    );
  }

  bool get isRunning => !_disposed && _showcaseView.isShowcaseRunning;

  FloatingActionWidget _buildSkipButton(BuildContext context) {
    return FloatingActionWidget.directional(
      textDirection: Directionality.of(context),
      top: MediaQuery.paddingOf(context).top + 12,
      end: 16,
      child: TextButton.icon(
        onPressed: _showcaseView.dismiss,
        style: TextButton.styleFrom(
          backgroundColor: AppTheme.cream,
          foregroundColor: AppTheme.navy,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        icon: const Icon(Icons.close, size: 18),
        label: Text(context.l10n.business_setup_tour_skip),
      ),
    );
  }

  void scheduleStartOnce({
    required String ownerId,
    required String journeyId,
    required List<GlobalKey> keys,
  }) {
    if (_disposed || keys.isEmpty) return;
    final scheduleId = '$ownerId:$journeyId';
    if (!_scheduledJourneys.add(scheduleId) ||
        (_storage?.isCompleted(ownerId, journeyId: journeyId) ?? false)) {
      return;
    }

    _completionOwnerId = ownerId;
    _completionJourneyId = journeyId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      start(keys);
    });
  }

  void start(List<GlobalKey> keys) {
    if (_disposed || keys.isEmpty || _showcaseView.isShowcaseRunning) return;
    _showcaseView.startShowCase(
      keys,
      delay: const Duration(milliseconds: 250),
    );
  }

  void dismiss() {
    if (!_disposed && _showcaseView.isShowcaseRunning) {
      _showcaseView.dismiss();
    }
  }

  void _completeTour() {
    BusinessShowcaseInteractionLock.unlock(scope);
    final ownerId = _completionOwnerId;
    final journeyId = _completionJourneyId;
    if (ownerId == null || journeyId == null) return;
    final storage = _storage;
    if (storage != null) {
      unawaited(storage.markCompleted(ownerId, journeyId: journeyId));
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    BusinessShowcaseInteractionLock.unlock(scope);
    _showcaseView.unregister();
  }
}

class BusinessShowcaseStep extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String scope;
  final String title;
  final String description;
  final int index;
  final int itemCount;
  final Widget child;
  final BorderRadius targetBorderRadius;
  final EdgeInsets targetPadding;

  const BusinessShowcaseStep({
    super.key,
    required this.showcaseKey,
    required this.scope,
    required this.title,
    required this.description,
    required this.index,
    required this.itemCount,
    required this.child,
    this.targetBorderRadius = const BorderRadius.all(Radius.circular(16)),
    this.targetPadding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    return Showcase(
      key: showcaseKey,
      scope: scope,
      title: title,
      description: description,
      titleTextDirection: textDirection,
      descriptionTextDirection: textDirection,
      titleTextAlign: TextAlign.start,
      descriptionTextAlign: TextAlign.start,
      titleTextStyle: const TextStyle(
        color: AppTheme.navy,
        fontSize: 19,
        fontWeight: FontWeight.w800,
      ),
      descTextStyle: const TextStyle(
        color: AppTheme.ink,
        fontSize: 16,
        height: 1.35,
      ),
      tooltipBackgroundColor: AppTheme.cream,
      tooltipBorderRadius: BorderRadius.circular(16),
      tooltipPadding: const EdgeInsets.all(16),
      targetBorderRadius: targetBorderRadius,
      targetPadding: targetPadding,
      overlayColor: AppTheme.navy,
      overlayOpacity: 0.88,
      disableDefaultTargetGestures: true,
      disableBarrierInteraction: true,
      enableAutoScroll: true,
      scrollAlignment: 0.5,
      tooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 8,
        gapBetweenContentAndAction: 14,
      ),
      tooltipActions: _actions(context),
      child: child,
    );
  }

  List<TooltipActionButton> _actions(BuildContext context) {
    const actionTextStyle = TextStyle(
      color: AppTheme.cream,
      fontWeight: FontWeight.w700,
    );
    return [
      if (index > 0)
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          name: context.l10n.business_setup_tour_previous,
          backgroundColor: AppTheme.slate,
          textStyle: actionTextStyle,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        ),
      TooltipActionButton(
        type: TooltipDefaultActionType.next,
        name: index == itemCount - 1
            ? context.l10n.business_setup_tour_done
            : context.l10n.business_setup_tour_next,
        backgroundColor: AppTheme.navy,
        textStyle: actionTextStyle,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      ),
    ];
  }
}

class BusinessShowcaseHelpButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BusinessShowcaseHelpButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.business_setup_tour_restart,
      onPressed: onPressed,
      icon: const Icon(Icons.help_outline_rounded),
    );
  }
}
