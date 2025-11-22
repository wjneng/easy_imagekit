import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:easy_imagekit/core/image_type_detector.dart';
import 'package:easy_imagekit/models/image_source.dart';
import 'package:easy_imagekit/models/image_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageLoader {
  /// 加载图片并返回合适的Widget
  static Widget loadImage(ImageSource source, ImageStyle style,
      {Widget? placeholder,
      Widget? errorWidget,
      VoidCallback? onTap,
      bool Function()? shouldRepaint}) {
    // 构建基础容器
    Widget imageWidget;

    switch (source.type) {
      case ImageSourceType.network:
        imageWidget = _loadNetworkImage(
            source.data as String, source.format, style,
            placeholder: placeholder, errorWidget: errorWidget);
        break;

      case ImageSourceType.asset:
        imageWidget = _loadAssetImage(
            source.data as String, source.format, style,
            placeholder: placeholder, errorWidget: errorWidget);
        break;

      case ImageSourceType.file:
        imageWidget = _loadFileImage(
            source.data as String, source.format, style,
            placeholder: placeholder, errorWidget: errorWidget);
        break;

      case ImageSourceType.memory:
        imageWidget = _loadMemoryImage(
            source.data as Uint8List, source.format, style,
            placeholder: placeholder, errorWidget: errorWidget);
        break;

      case ImageSourceType.base64:
        try {
          final bytes = ImageTypeDetector.base64ToBytes(source.data as String);
          imageWidget = _loadMemoryImage(bytes, source.format, style,
              placeholder: placeholder, errorWidget: errorWidget);
        } catch (e) {
          imageWidget = errorWidget ?? _defaultErrorWidget(style);
        }
        break;

      default:
        imageWidget = errorWidget ?? _defaultErrorWidget(style);
    }

    // 应用样式包装
    return _wrapWithStyle(imageWidget, style, onTap: onTap);
  }

  /// 加载网络图片
  static Widget _loadNetworkImage(
      String url, ImageFormat? format, ImageStyle style,
      {Widget? placeholder, Widget? errorWidget}) {
    if (format == ImageFormat.svg || url.endsWith('.svg')) {
      return SvgPicture.network(
        url,
        width: style.width,
        height: style.height,
        fit: style.fit,
        placeholderBuilder: (context) =>
            placeholder ?? _defaultPlaceholderWidget(style),
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _defaultErrorWidget(style),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: style.width,
      height: style.height,
      fit: style.fit,
      color: style.color,
      colorBlendMode: style.colorBlendMode,
      placeholder: (context, url) =>
          placeholder ?? _defaultPlaceholderWidget(style),
      errorWidget: (context, url, error) =>
          errorWidget ?? _defaultErrorWidget(style),
      memCacheWidth: style.maxWidth?.toInt(),
      memCacheHeight: style.maxHeight?.toInt(),
    );
  }

  /// 加载Asset图片
  static Widget _loadAssetImage(
      String assetPath, ImageFormat? format, ImageStyle style,
      {Widget? placeholder, Widget? errorWidget}) {
    if (format == ImageFormat.svg || assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: style.width,
        height: style.height,
        fit: style.fit,
        colorFilter: style.color == null
            ? null
            : ColorFilter.mode(style.color ?? Colors.transparent,
                style.colorBlendMode ?? BlendMode.srcIn),
        placeholderBuilder: (context) =>
            placeholder ?? _defaultPlaceholderWidget(style),
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _defaultErrorWidget(style),
      );
    }

    return Image.asset(
      assetPath,
      width: style.width,
      height: style.height,
      fit: style.fit,
      color: style.color,
      colorBlendMode: style.colorBlendMode,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultErrorWidget(style),
      gaplessPlayback: true,
    );
  }

  /// 加载本地文件图片
  static Widget _loadFileImage(
      String filePath, ImageFormat? format, ImageStyle style,
      {Widget? placeholder, Widget? errorWidget}) {
    final file = File(filePath.replaceFirst('file://', ''));
    if (!file.existsSync()) {
      return errorWidget ?? _defaultErrorWidget(style);
    }

    if (format == ImageFormat.svg || filePath.endsWith('.svg')) {
      return SvgPicture.file(
        file,
        width: style.width,
        height: style.height,
        fit: style.fit,
        colorFilter: style.color == null
            ? null
            : ColorFilter.mode(style.color ?? Colors.transparent,
                style.colorBlendMode ?? BlendMode.srcIn),
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _defaultErrorWidget(style),
      );
    }

    return Image.file(
      file,
      width: style.width,
      height: style.height,
      fit: style.fit,
      color: style.color,
      colorBlendMode: style.colorBlendMode,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultErrorWidget(style),
      gaplessPlayback: true,
    );
  }

  /// 加载内存图片
  static Widget _loadMemoryImage(
      Uint8List bytes, ImageFormat? format, ImageStyle style,
      {Widget? placeholder, Widget? errorWidget}) {
    if (format == ImageFormat.svg ||
        (format == ImageFormat.unknown && _isSvgBytes(bytes))) {
      try {
        return SvgPicture.memory(
          bytes,
          width: style.width,
          height: style.height,
          fit: style.fit,
          colorFilter: style.color == null
              ? null
              : ColorFilter.mode(style.color ?? Colors.transparent,
                  style.colorBlendMode ?? BlendMode.srcIn),
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _defaultErrorWidget(style),
        );
      } catch (e) {
        return errorWidget ?? _defaultErrorWidget(style);
      }
    }

    return Image.memory(
      bytes,
      width: style.width,
      height: style.height,
      fit: style.fit,
      color: style.color,
      colorBlendMode: style.colorBlendMode,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultErrorWidget(style),
      gaplessPlayback: true,
    );
  }

  /// 判断字节是否为SVG
  static bool _isSvgBytes(Uint8List bytes) {
    if (bytes.length < 5) return false;
    final header =
        utf8.decode(bytes.sublist(0, 5).toList(), allowMalformed: true);
    return header.startsWith('<?xml') || header.startsWith('<svg');
  }

  /// 默认占位图
  static Widget _defaultPlaceholderWidget(ImageStyle style) {
    return Container(
      width: style.width,
      height: style.height,
      color: style.placeholderColor ?? Colors.grey[200],
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  /// 默认错误图
  static Widget _defaultErrorWidget(ImageStyle style) {
    return Container(
      width: style.width,
      height: style.height,
      color: style.errorColor ?? Colors.grey[100],
      child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 32)),
    );
  }

  /// 应用样式包装
  static Widget _wrapWithStyle(Widget child, ImageStyle style,
      {VoidCallback? onTap}) {
    // 构建圆角
    BorderRadiusGeometry borderRadius =
        style.borderRadiusGeometry ?? BorderRadius.circular(style.borderRadius);

    // 如果是圆形裁剪，重写圆角
    if (style.isCircle) {
      borderRadius = BorderRadius.circular(1000);
    }

    // 基础容器
    Widget container = Container(
      width: style.width,
      height: style.height,
      constraints: BoxConstraints(
          maxWidth: style.maxWidth ?? double.infinity,
          maxHeight: style.maxHeight ?? double.infinity),
      decoration: BoxDecoration(
          color: style.backgroundColor,
          border: style.border,
          borderRadius: borderRadius,
          boxShadow: style.boxShadow),
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: style.clipBehavior,
        child: Opacity(
          opacity: style.opacity.clamp(0.0, 1.0),
          child: ImageFiltered(
            imageFilter:
                style.imageFilter ?? ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Align(alignment: style.alignment, child: child),
          ),
        ),
      ),
    );

    // 添加点击事件
    if (onTap != null) {
      container = GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}
