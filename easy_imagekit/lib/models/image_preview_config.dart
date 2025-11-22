import 'package:flutter/material.dart';

/// 图片预览配置类
class ImagePreviewConfig {
  /// 是否启用点击放大预览
  final bool enable;

  /// 多图预览时的图片列表（单图时可不传，默认使用当前图片）
  final List<dynamic>? images;

  /// 多图预览的初始显示索引
  final int initialIndex;

  /// 是否支持循环滑动（多图时）
  final bool loop;

  /// 预览时最小缩放比例
  final double minScale;

  /// 预览时最大缩放比例
  final double maxScale;

  /// 预览页面背景色
  final Color backgroundColor;

  /// 关闭按钮颜色
  final Color closeBtnColor;

  /// 滑动阈值（超过该距离视为滑动，不触发关闭）
  final double slideThreshold;

  /// 双击间隔
  final Duration doubleTapDuration;

  /// 多页自定义底部组件列表（与 images 一一对应）
  /// 长度需与 images 一致，若某一页无需自定义组件可传 null
  final List<Widget?>? customBottomWidgets;

  /// 自定义底部区域内边距（默认：上下12px，左右16px）
  final EdgeInsetsGeometry customBottomPadding;

  /// 底部区域与屏幕底部的间距（默认20px）
  final double bottomMargin;

  /// 底部区域与图片底部的间距（默认16px）
  final double bottomToImageSpacing;

  /// 构造函数
  const ImagePreviewConfig({
    this.enable = true,
    this.images,
    this.initialIndex = 0,
    this.loop = true,
    this.minScale = 0.8,
    this.maxScale = 3.0,
    this.backgroundColor = Colors.black,
    this.closeBtnColor = Colors.white,
    this.slideThreshold = 10.0,
    this.doubleTapDuration = const Duration(milliseconds: 300),
    this.customBottomWidgets,
    this.customBottomPadding = EdgeInsets.zero,
    this.bottomMargin = 20.0,
    this.bottomToImageSpacing = 16.0,
  });

  ImagePreviewConfig copyWith({
    bool? enable,
    List<dynamic>? images,
    int? initialIndex,
    bool? loop,
    double? minScale,
    double? maxScale,
    Color? backgroundColor,
    Color? closeBtnColor,
    double? slideThreshold,
    Duration? doubleTapDuration,
    List<Widget?>? customBottomWidgets,
    EdgeInsetsGeometry? customBottomPadding,
    double? bottomMargin,
    double? bottomToImageSpacing,
  }) {
    return ImagePreviewConfig(
      enable: enable ?? this.enable,
      images: images ?? this.images,
      initialIndex: initialIndex ?? this.initialIndex,
      loop: loop ?? this.loop,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      closeBtnColor: closeBtnColor ?? this.closeBtnColor,
      slideThreshold: slideThreshold ?? this.slideThreshold,
      doubleTapDuration: doubleTapDuration ?? this.doubleTapDuration,
      customBottomWidgets: customBottomWidgets ?? this.customBottomWidgets,
      customBottomPadding: customBottomPadding ?? this.customBottomPadding,
      bottomMargin: bottomMargin ?? this.bottomMargin,
      bottomToImageSpacing: bottomToImageSpacing ?? this.bottomToImageSpacing,
    );
  }

  /// 默认配置
  static const ImagePreviewConfig defaultConfig = ImagePreviewConfig();

  /// 禁用预览的配置
  static const ImagePreviewConfig disabled = ImagePreviewConfig(enable: false);
}
