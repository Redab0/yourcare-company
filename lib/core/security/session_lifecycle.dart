import 'dart:async';
import 'package:flutter/widgets.dart';
import 'session_renewal_coordinator.dart';

class SessionLifecycle extends StatefulWidget {
  const SessionLifecycle(
      {super.key, required this.sessions, this.onResume, required this.child});
  final SessionRenewalCoordinator sessions;
  final Widget child;
  final Future<void> Function()? onResume;
  @override
  State<SessionLifecycle> createState() => _SessionLifecycleState();
}

class _SessionLifecycleState extends State<SessionLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _renew();
  }

  void _renew() =>
      unawaited(widget.sessions.ensureSession().then<void>((_) async {
        await widget.onResume?.call();
      }, onError: (Object _, StackTrace __) {}));
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _renew();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
