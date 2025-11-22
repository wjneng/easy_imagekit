import 'dart:ui';
import 'package:flutter/material.dart';

class ImageStyle {
  /// 宽度（默认：自适应）
  final double? width;

  /// 高度（默认：自适应）
  final double? height;

  /// 最大宽度
  final double? maxWidth;

  /// 最大高度
  final double? maxHeight;

  /// 圆角（默认：0）
  final double borderRadius;

  /// 圆角配置（优先级高于borderRadius）
  final BorderRadiusGeometry? borderRadiusGeometry;

  /// 边框
  final BoxBorder? border;

  /// 阴影
  final List<BoxShadow>? boxShadow;

  /// 背景色
  final Color? backgroundColor;

  /// 图片颜色（会覆盖图片原有颜色）
  final Color? color;

  /// 颜色混合模式
  final BlendMode? colorBlendMode;

  /// 滤镜
  final ImageFilter? imageFilter;

  /// 填充模式（默认：cover）
  final BoxFit fit;

  /// 对齐方式（默认：center）
  final Alignment alignment;

  /// 重复模式
  final ImageRepeat repeat;

  /// 透明度（0-1，默认：1）
  final double opacity;

  /// 剪裁行为（默认：hardEdge）
  final Clip clipBehavior;

  /// 是否圆形裁剪（优先级高于圆角）
  final bool isCircle;

  /// 占位图颜色
  final Color? placeholderColor;

  /// 错误图颜色
  final Color? errorColor;

  const ImageStyle({
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.borderRadius = 0,
    this.borderRadiusGeometry,
    this.border,
    this.boxShadow,
    this.backgroundColor,
    this.color,
    this.colorBlendMode,
    this.imageFilter,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.opacity = 1.0,
    this.clipBehavior = Clip.hardEdge,
    this.isCircle = false,
    this.placeholderColor,
    this.errorColor,
  });

  ImageStyle copyWith({
    double? width,
    double? height,
    double? maxWidth,
    double? maxHeight,
    double? borderRadius,
    BorderRadiusGeometry? borderRadiusGeometry,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Color? backgroundColor,
    Color? color,
    BlendMode? colorBlendMode,
    ImageFilter? imageFilter,
    BoxFit? fit,
    Alignment? alignment,
    ImageRepeat? repeat,
    double? opacity,
    Clip? clipBehavior,
    bool? isCircle,
    Color? placeholderColor,
    Color? errorColor,
  }) {
    return ImageStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      borderRadiusGeometry: borderRadiusGeometry ?? this.borderRadiusGeometry,
      border: border ?? this.border,
      boxShadow: boxShadow ?? this.boxShadow,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      color: color ?? this.color,
      colorBlendMode: colorBlendMode ?? this.colorBlendMode,
      imageFilter: imageFilter ?? this.imageFilter,
      fit: fit ?? this.fit,
      alignment: alignment ?? this.alignment,
      repeat: repeat ?? this.repeat,
      opacity: opacity ?? this.opacity,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      isCircle: isCircle ?? this.isCircle,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }
}
