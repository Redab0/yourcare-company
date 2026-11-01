import 'package:flutter/material.dart';
import '../core/access/company_permission_context.dart';
import '../core/access/price_access.dart';
import '../core/utils/context_extensions.dart';
import '../data/models/staff/permission_model.dart';
import 'permission_editor.dart';

class CompanyPermissionPanel extends StatefulWidget {
  const CompanyPermissionPanel(
      {super.key,
      required this.selectedIds,
      required this.onChanged,
      this.existing = const [],
      this.loader});
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final List<PermissionModel> existing;
  final CompanyPermissionContextLoader? loader;
  @override
  State<CompanyPermissionPanel> createState() => _CompanyPermissionPanelState();
}

class _CompanyPermissionPanelState extends State<CompanyPermissionPanel> {
  late CompanyPermissionContextLoader _loader;
  CompanyPermissionContext? _context;
  int _request = 0;
  bool _loading = true;
  late final int _enteredGeneration;
  @override
  void initState() {
    super.initState();
    _loader = widget.loader ?? CompanyPermissionContextLoader.application();
    _enteredGeneration = _loader.generation();
    PriceAccess.instance.addListener(_accountChanged);
    _load();
  }

  void _accountChanged() {
    if (_loader.generation() != _enteredGeneration && mounted) {
      _request++;
      setState(() {
        _context = null;
        _loading = false;
      });
    }
  }

  Future<void> _load() async {
    if (_loader.generation() != _enteredGeneration) return;
    final request = ++_request;
    if (mounted) {
      setState(() {
        _loading = true;
        _context = null;
      });
    }
    CompanyPermissionContext? result;
    try {
      result = await _loader.load();
    } catch (_) {/* Show retry, never stale options. */}
    if (!mounted || request != _request) return;
    setState(() {
      _context = result != null && _loader.current(result) ? result : null;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _request++;
    PriceAccess.instance.removeListener(_accountChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ListTile(
          leading: const SizedBox(
              width: 22, height: 22, child: CircularProgressIndicator()),
          title: Text(context.l10n.permissionOptionsLoading));
    }
    final snapshot = _context;
    if (snapshot == null || !_loader.current(snapshot)) {
      return Column(children: [
        Text(context.l10n.permissionOptionsUnavailable),
        TextButton(onPressed: _load, child: Text(context.l10n.retry)),
      ]);
    }
    return Column(children: [
      if (snapshot.servicesUnavailable) ...[
        Text(context.l10n.permissionServiceContextUnavailable),
        TextButton(onPressed: _load, child: Text(context.l10n.retry)),
      ],
      if (snapshot.options.isEmpty) Text(context.l10n.permissionOptionsEmpty),
      PermissionEditor(
          catalog: snapshot.options,
          existing: widget.existing,
          selectedIds: widget.selectedIds,
          onChanged: (next) {
            if (_loader.current(snapshot)) {
              widget.onChanged(next);
            } else {
              _load();
            }
          }),
    ]);
  }
}
