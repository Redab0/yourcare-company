/// Local client safeguards validated before multipart allocation.
/// These ceilings do not establish server-side upload enforcement.
class UploadFileSize {
  const UploadFileSize(this.bytes, {this.isVideo = false});
  final int bytes;
  final bool isVideo;
}

abstract final class UploadLimits {
  static const imageMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/bmp',
    'image/tiff',
    'image/avif',
    'image/heic',
    'image/heif',
  };
  static void validateFilename(String? filename) {
    if (filename == null ||
        filename.isEmpty ||
        filename.length > 255 ||
        filename == '.' ||
        filename == '..' ||
        filename.contains(RegExp(r'[\x00-\x1f\x7f/\\]'))) {
      throw const FormatException('Invalid upload filename.');
    }
  }

  /// Inspect a bounded file header, never trust an extension/MIME claim alone.
  static String imageMime(List<int> bytes) {
    bool starts(List<int> prefix) =>
        bytes.length >= prefix.length &&
        List.generate(prefix.length, (i) => bytes[i] == prefix[i])
            .every((v) => v);
    String ascii(int from, int to) =>
        bytes.length >= to ? String.fromCharCodes(bytes.sublist(from, to)) : '';
    if (starts([0xff, 0xd8, 0xff])) return 'image/jpeg';
    if (starts([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])) {
      return 'image/png';
    }
    if ({'GIF87a', 'GIF89a'}.contains(ascii(0, 6))) return 'image/gif';
    if (ascii(0, 4) == 'RIFF' && ascii(8, 12) == 'WEBP') return 'image/webp';
    if (ascii(0, 2) == 'BM') return 'image/bmp';
    if (starts([0x49, 0x49, 0x2a, 0]) || starts([0x4d, 0x4d, 0, 0x2a])) {
      return 'image/tiff';
    }
    if (ascii(4, 8) == 'ftyp') {
      final brand = ascii(8, 12);
      if ({'heic', 'heix', 'hevc', 'hevx'}.contains(brand)) return 'image/heic';
      if ({'mif1', 'msf1'}.contains(brand)) return 'image/heif';
      if ({'avif', 'avis'}.contains(brand)) return 'image/avif';
    }
    throw const FormatException('Choose a supported image file.');
  }

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
