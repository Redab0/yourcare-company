import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cleaning_service_driver/data/models/documents/business_document.dart';
import 'package:cleaning_service_driver/domain/usecases/documents/documents_usecases.dart';

class DocumentsState {
  final DocumentPage? result;
  final bool loading, failed;
  const DocumentsState(
      {this.result, this.loading = false, this.failed = false});
}

class DocumentsCubit extends Cubit<DocumentsState> {
  final DocumentsUseCases useCases;
  String? search, category;
  int _request = 0;
  DocumentsCubit(this.useCases) : super(const DocumentsState());
  Future<void> load({int page = 1}) async {
    final request = ++_request;
    emit(DocumentsState(result: state.result, loading: true));
    try {
      final result =
          await useCases.list(page: page, search: search, category: category);
      if (!isClosed && request == _request) {
        emit(DocumentsState(result: result));
      }
    } catch (_) {
      if (!isClosed && request == _request) {
        emit(DocumentsState(result: state.result, failed: true));
      }
    }
  }

  Future<Uint8List> download(String id) => useCases.download(id);
}
