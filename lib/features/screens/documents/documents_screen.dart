import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/documents/business_document.dart';
import 'package:cleaning_service_driver/features/bloc/documents/documents_cubit.dart';
import 'package:cleaning_service_driver/features/screens/documents/document_file_saver.dart';
import 'package:cleaning_service_driver/features/screens/documents/document_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentsScreen extends StatefulWidget {
  final DocumentsCubit? cubit;
  const DocumentsScreen({super.key, this.cubit});
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late final DocumentsCubit _cubit = widget.cubit ?? sl<DocumentsCubit>();
  final _search = TextEditingController();
  final _busyDocuments = <String>{};
  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  void dispose() {
    if (widget.cubit == null) _cubit.close();
    _search.dispose();
    super.dispose();
  }

  String _category(String value) => switch (value) {
        'policy' => context.l10n.documentPolicy,
        'contract' => context.l10n.documentContract,
        _ => context.l10n.documentOther
      };
  Future<void> _download(BusinessDocument doc) async {
    if (_busyDocuments.contains(doc.id)) return;
    setState(() => _busyDocuments.add(doc.id));
    try {
      final bytes = await _cubit.download(doc.id);
      if (!mounted) return;
      final saved = await saveBusinessDocument(doc, bytes);
      if (mounted && saved) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.documentDownloaded)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.documentsError)));
      }
    } finally {
      if (mounted) setState(() => _busyDocuments.remove(doc.id));
    }
  }

  Future<void> _open(BusinessDocument doc) async {
    if (_busyDocuments.contains(doc.id)) return;
    setState(() => _busyDocuments.add(doc.id));
    try {
      final bytes = await _cubit.download(doc.id);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => DocumentViewerScreen(document: doc, bytes: bytes),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.documentPreviewError)),
        );
      }
    } finally {
      if (mounted) setState(() => _busyDocuments.remove(doc.id));
    }
  }

  Widget _documentTile(BusinessDocument doc) {
    final isImage = doc.mimeType.toLowerCase().startsWith('image/');
    final busy = _busyDocuments.contains(doc.id);
    final l = context.l10n;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : () => _open(doc),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.illustrationBlueSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: busy
                        ? const AppIconSpinner(
                            assetPath: 'assets/images/ic_yourcare.png',
                            size: 48,
                          )
                        : Icon(
                            isImage
                                ? Icons.image_rounded
                                : Icons.description_rounded,
                            size: 76,
                            color: AppTheme.illustrationBlue,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                doc.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                _category(doc.category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: busy ? null : () => _open(doc),
                      icon: const Icon(Icons.visibility_rounded, size: 18),
                      label: Text(l.documentView),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.illustrationBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l.documentDownload,
                    onPressed: busy ? null : () => _download(doc),
                    icon: const Icon(Icons.download_rounded),
                    color: AppTheme.illustrationBlue,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
        appBar: AppBar(
            title: Text(l.documentsCenter),
            leading: const BusinessBackButton(fallbackRouteName: 'home'),
            actions: [
              IconButton(
                  tooltip: l.documentRefresh,
                  onPressed: () => _cubit.load(),
                  icon: const Icon(Icons.refresh))
            ]),
        body: BlocBuilder<DocumentsCubit, DocumentsState>(
            bloc: _cubit,
            builder: (context, state) => Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(children: [
                      Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            TextField(
                                controller: _search,
                                decoration: InputDecoration(
                                    labelText: l.documentSearch,
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: IconButton(
                                        tooltip: l.documentSearch,
                                        onPressed: () {
                                          _cubit.search = _search.text.trim();
                                          _cubit.load();
                                        },
                                        icon: const Icon(Icons.arrow_forward))),
                                onSubmitted: (v) {
                                  _cubit.search = v.trim();
                                  _cubit.load();
                                }),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                                initialValue: '',
                                isExpanded: true,
                                decoration: InputDecoration(
                                    labelText: l.documentCategory),
                                items: [
                                  DropdownMenuItem(
                                      value: '',
                                      child: Text(l.documentAllCategories)),
                                  for (final v in [
                                    'policy',
                                    'contract',
                                    'other'
                                  ])
                                    DropdownMenuItem(
                                        value: v, child: Text(_category(v)))
                                ],
                                onChanged: (v) {
                                  _cubit.category = v == '' ? null : v;
                                  _cubit.load();
                                }),
                          ])),
                      if (state.failed)
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: [
                              Text(l.documentsError),
                              TextButton(
                                  onPressed: () => _cubit.load(),
                                  child: Text(l.documentRetry))
                            ])),
                      Expanded(
                          child: state.loading
                              ? const Center(
                                  child: AppIconSpinner(
                                      assetPath:
                                          'assets/images/ic_yourcare.png'))
                              : (state.result?.docs.isEmpty ?? false)
                                  ? Center(child: Text(l.documentsEmpty))
                                  : RefreshIndicator(
                                      onRefresh: () => _cubit.load(
                                          page: state.result?.page ?? 1),
                                      child: GridView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 0, 16, 16),
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 220,
                                          mainAxisExtent: 240,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                        itemCount:
                                            state.result?.docs.length ?? 0,
                                        itemBuilder: (context, i) =>
                                            _documentTile(
                                                state.result!.docs[i]),
                                      ))),
                      if (state.result != null && state.result!.totalPages > 1)
                        SafeArea(
                            top: false,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      tooltip: l.documentPrevious,
                                      onPressed: state.loading ||
                                              state.result!.page <= 1
                                          ? null
                                          : () => _cubit.load(
                                              page: state.result!.page - 1),
                                      icon: const Icon(Icons.chevron_left)),
                                  Text(
                                      '${state.result!.page} / ${state.result!.totalPages}'),
                                  IconButton(
                                      tooltip: l.documentNext,
                                      onPressed: state.loading ||
                                              state.result!.page >=
                                                  state.result!.totalPages
                                          ? null
                                          : () => _cubit.load(
                                              page: state.result!.page + 1),
                                      icon: const Icon(Icons.chevron_right)),
                                ])),
                    ])))));
  }
}
