import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_imagekit/core/image_type_detector.dart';

/// 图片资源类型枚举
enum ImageSourceType {
  network, // 网络图片
  asset, // Asset资源
  file, // 本地文件
  memory, // 内存数据
  base64, // Base64编码
  unknown, // 未知类型
}

/// 图片格式枚举
enum ImageFormat { png, jpg, jpeg, gif, webp, svg, bmp, tiff, unknown }

/// 图片资源封装类
class ImageSource {
  final dynamic data;
  final ImageSourceType type;
  final ImageFormat? format;

  /// 网络图片
  ImageSource.network(String url, {ImageFormat? format})
      : data = url,
        type = ImageSourceType.network,
        format = format ?? ImageFormat.unknown;

  /// Asset图片
  ImageSource.asset(String assetPath, {ImageFormat? format})
      : data = assetPath,
        type = ImageSourceType.asset,
        format = format ?? ImageFormat.unknown;

  /// 本地文件图片
  ImageSource.file(String filePath, {ImageFormat? format})
      : data = filePath,
        type = ImageSourceType.file,
        format = format ?? ImageFormat.unknown;

  /// 内存图片
  ImageSource.memory(Uint8List bytes, {ImageFormat? format})
      : data = bytes,
        type = ImageSourceType.memory,
        format = format ?? ImageFormat.unknown;

  /// Base64图片
  ImageSource.base64(String base64String, {ImageFormat? format})
      : data = base64String,
        type = ImageSourceType.base64,
        format = format ?? ImageFormat.unknown;

  /// 自动识别图片资源
  factory ImageSource.auto(dynamic data) {
    if (data == null) {
      return ImageSource.network('');
    }

    // 识别Base64
    if (data is String && _isBase64(data)) {
      final format = ImageTypeDetector.detectFromBase64(data);
      return ImageSource.base64(data, format: format);
    }

    // 识别网络图片
    if (data is String && _isNetworkUrl(data)) {
      final format = ImageTypeDetector.detectFromUrl(data);
      return ImageSource.network(data, format: format);
    }

    // 识别Asset（简单判断：非路径、非URL的字符串）
    if (data is String && !_isFilePath(data) && !_isNetworkUrl(data)) {
      final format = ImageTypeDetector.detectFromFileName(data);
      return ImageSource.asset(data, format: format);
    }

    // 识别文件路径
    if (data is String && _isFilePath(data)) {
      final format = ImageTypeDetector.detectFromFileName(data);
      return ImageSource.file(data, format: format);
    }

    // 识别内存数据
    if (data is Uint8List) {
      final format = ImageTypeDetector.detectFromBytes(data);
      return ImageSource.memory(data, format: format);
    }

    return ImageSource.network(data.toString());
  }

  /// 判断是否为Base64字符串
  static bool _isBase64(String str) {
    // 先清理可能的前缀
    final cleaned = str.replaceFirst(
      RegExp(r'^data:image/[a-zA-Z0-9]+;base64,'),
      '',
    );
    // Base64 正则：只包含 A-Z, a-z, 0-9, +, /, = 字符，长度符合 Base64 规范
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$', caseSensitive: false);
    // 验证格式并尝试解码（双重验证）
    if (base64Regex.hasMatch(cleaned)) {
      try {
        base64Decode(cleaned); // 尝试解码，验证有效性
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// 判断是否为网络URL
  static bool _isNetworkUrl(String str) {
    return str.startsWith(RegExp(r'^https?://', caseSensitive: false));
  }

  /// 判断是否为文件路径
  static bool _isFilePath(String str) {
    return str.startsWith('/') ||
        str.contains(RegExp(r'^[A-Za-z]:\\', caseSensitive: false)) ||
        str.startsWith('file://');
  }
}
