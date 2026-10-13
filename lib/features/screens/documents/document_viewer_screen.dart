import 'dart:async';
import 'dart:typed_data';

import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/documents/business_document.dart';
import 'package:cleaning_service_driver/features/screens/documents/document_file_saver.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class DocumentViewerScreen extends StatefulWidget {
  final BusinessDocument document;
  final Uint8List bytes;

  const DocumentViewerScreen({
    super.key,
    required this.document,
    required this.bytes,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _saving = false;
  Future<void>? _pdfInitialization;
  PdfDocumentRefByLoader? _pdfReference;

  bool get _isPdf {
    final mimeType = widget.document.mimeType.toLowerCase();
    return mimeType == 'application/pdf' ||
        widget.document.fileName.toLowerCase().endsWith('.pdf');
  }

  bool get _hasPdfHeader =>
      String.fromCharCodes(widget.bytes.take(1024)).contains('%PDF-');

  @override
  void initState() {
    super.initState();
    if (_isPdf && _hasPdfHeader) {
      final sourceName =
          '${widget.document.id}/${widget.document.fileName}/${identityHashCode(widget.bytes)}';
      _pdfReference = PdfDocumentRefByLoader(
        (_) => PdfDocument.openData(
          widget.bytes,
          sourceName: sourceName,
          useProgressiveLoading: false,
        ).timeout(const Duration(seconds: 20)),
        key: PdfDocumentRefKey(sourceName),
      );
      // Wait for native PDFium setup before PdfViewer builds, so the viewer and
      // its document loader cannot start the same initialization concurrently.
      _pdfInitialization =
          pdfrxFlutterInitialize().timeout(const Duration(seconds: 20));
    }
  }

  Future<void> _download() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final saved = await saveBusinessDocument(widget.document, widget.bytes);
      if (mounted && saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.documentDownloaded)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.documentsError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mimeType = widget.document.mimeType.toLowerCase();
    final fileName = widget.document.fileName.toLowerCase();
    final isPdf = _isPdf;
    final isImage = mimeType == 'image/png' ||
        mimeType == 'image/jpeg' ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg');

    Widget preview;
    if (isPdf) {
      preview = !_hasPdfHeader
          ? Center(child: Text(context.l10n.documentPreviewError))
          : FutureBuilder<void>(
              future: _pdfInitialization,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error is TimeoutException
                        ? context.l10n.documentPreviewTimeout
                        : context.l10n.documentPreviewError),
                  );
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: AppIconSpinner(
                        assetPath: 'assets/images/ic_yourcare.png'),
                  );
                }
                return PdfViewer(
                  _pdfReference!,
                  params: PdfViewerParams(
                    loadingBannerBuilder: (_, __, ___) => const Center(
                      child: AppIconSpinner(
                          assetPath: 'assets/images/ic_yourcare.png'),
                    ),
                    errorBannerBuilder: (context, error, __, ___) => Center(
                      child: Text(error is TimeoutException
                          ? context.l10n.documentPreviewTimeout
                          : context.l10n.documentPreviewError),
                    ),
                  ),
                );
              },
            );
    } else if (isImage) {
      preview = LayoutBuilder(
        builder: (context, constraints) => InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Image.memory(
              widget.bytes,
              fit: BoxFit.contain,
              errorBuilder: (context, _, __) =>
                  Center(child: Text(context.l10n.documentPreviewError)),
            ),
          ),
        ),
      );
    } else {
      preview = Center(child: Text(context.l10n.documentPreviewUnsupported));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: context.l10n.documentDownload,
            onPressed: _saving ? null : _download,
            icon: _saving
                ? const AppIconSpinner(
                    assetPath: 'assets/images/ic_yourcare.png', size: 24)
                : const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: SafeArea(child: preview),
    );
  }
}
