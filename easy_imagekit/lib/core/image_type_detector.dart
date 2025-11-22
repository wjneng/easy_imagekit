import 'dart:typed_data';
import 'package:easy_imagekit/models/image_source.dart';
import 'package:mime/mime.dart';
import 'dart:convert';

class ImageTypeDetector {
  /// 从URL识别图片格式
  static ImageFormat detectFromUrl(String url) {
    final fileName = url.split('?').first.split('/').last;
    return detectFromFileName(fileName);
  }

  /// 从文件名识别图片格式
  static ImageFormat detectFromFileName(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return _getFormatFromExtension(ext);
  }

  /// 从Base64识别图片格式
  static ImageFormat detectFromBase64(String base64) {
    if (base64.startsWith(RegExp(r'^data:image/', caseSensitive: false))) {
      final mimeMatch = RegExp(
        r'data:image/([a-zA-Z0-9]+);',
      ).firstMatch(base64);
      if (mimeMatch != null && mimeMatch.groupCount >= 1) {
        final ext = mimeMatch.group(1)?.toLowerCase() ?? '';
        return _getFormatFromExtension(ext);
      }
    }
    // 如果没有MIME类型，尝试解码后识别
    try {
      final bytes = base64ToBytes(base64);
      return detectFromBytes(bytes);
    } catch (_) {
      return ImageFormat.unknown;
    }
  }

  /// 从字节数据识别图片格式
  static ImageFormat detectFromBytes(Uint8List bytes) {
    if (bytes.length < 4) return ImageFormat.unknown;

    // 检查文件签名（Magic Numbers）
    final header = bytes.sublist(0, 4);
    final headerInt = _bytesToInt(header);

    switch (headerInt) {
      case 0x89504E47: // PNG: 89 50 4E 47
        return ImageFormat.png;
      case 0xFFD8FFE0: // JPEG: FF D8 FF E0
      case 0xFFD8FFE1: // JPEG: FF D8 FF E1
      case 0xFFD8FFE2: // JPEG: FF D8 FF E2
        return ImageFormat.jpg;
      case 0x47494638: // GIF: 47 49 46 38
        return ImageFormat.gif;
      case 0x52494646: // WEBP: 52 49 46 46 (RIFF)
        if (bytes.length >= 12) {
          final webpHeader = bytes.sublist(8, 12);
          if (_bytesToInt(webpHeader) == 0x57454250) {
            // WEBP
            return ImageFormat.webp;
          }
        }
        break;
      case 0x3C3F786D: // SVG: <?xml
        return ImageFormat.svg;
      case 0x424D: // BMP: BM
        return ImageFormat.bmp;
      case 0x49492A00: // TIFF: II*
      case 0x4D4D002A: // TIFF: MM*
        return ImageFormat.tiff;
    }

    // 尝试通过MIME类型识别
    final mime = lookupMimeType('', headerBytes: bytes);
    if (mime != null) {
      final ext = mime.split('/').last.toLowerCase();
      return _getFormatFromExtension(ext);
    }

    return ImageFormat.unknown;
  }

  /// 从文件扩展名获取图片格式
  static ImageFormat _getFormatFromExtension(String ext) {
    switch (ext) {
      case 'png':
        return ImageFormat.png;
      case 'jpg':
      case 'jpeg':
        return ImageFormat.jpg;
      case 'gif':
        return ImageFormat.gif;
      case 'webp':
        return ImageFormat.webp;
      case 'svg':
        return ImageFormat.svg;
      case 'bmp':
        return ImageFormat.bmp;
      case 'tiff':
      case 'tif':
        return ImageFormat.tiff;
      default:
        return ImageFormat.unknown;
    }
  }

  /// Base64字符串转字节
  static Uint8List base64ToBytes(String base64) {
    final cleaned = base64.replaceFirst(
      RegExp(r'^data:image/[a-zA-Z0-9]+;base64,'),
      '',
    );
    return base64Decode(cleaned);
  }

  /// 字节转整数（用于文件签名识别）
  static int _bytesToInt(Uint8List bytes) {
    int result = 0;
    for (int i = 0; i < bytes.length; i++) {
      result = (result << 8) | bytes[i];
    }
    return result;
  }
}
