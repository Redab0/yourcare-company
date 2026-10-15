/// Mirrors the generic /upload/multiple contract; validates before multipart allocation.
class UploadFileSize {
  const UploadFileSize(this.bytes, {this.isVideo = false});
  final int bytes;
  final bool isVideo;
}

abstract final class UploadLimits {
  static const maxFiles = 10;
  static const maxImageBytes = 20 * 1024 * 1024;
  static const maxVideoBytes = 100 * 1024 * 1024;
  static const maxTotalBytes = 100 * 1024 * 1024;

  static void validate(List<UploadFileSize> files) {
    if (files.isEmpty || files.length > maxFiles) {
      throw const FormatException('Select between 1 and 10 files.');
    }
    var total = 0;
    for (final file in files) {
      if (file.bytes <= 0) {
        throw const FormatException('Empty files cannot be uploaded.');
      }
      final limit = file.isVideo ? maxVideoBytes : maxImageBytes;
      if (file.bytes > limit) {
        throw FormatException(file.isVideo
            ? 'Each video must be 100 MiB or smaller.'
            : 'Each image must be 20 MiB or smaller.');
      }
      total += file.bytes;
    }
    if (total > maxTotalBytes) {
      throw const FormatException('Selected files must total 100 MiB or less.');
    }
  }
}
