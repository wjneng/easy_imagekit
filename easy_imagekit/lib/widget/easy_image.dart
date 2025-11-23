import 'package:easy_imagekit/models/image_source.dart';
import 'package:easy_imagekit/models/image_style.dart';
import 'package:flutter/material.dart';
import 'image_loader.dart';

class EasyImage extends StatelessWidget {
  /// 图片资源（支持自动识别）
  final dynamic image;

  /// 样式配置
  final ImageStyle style;

  /// 占位图
  final Widget? placeholder;

  /// 错误图
  final Widget? errorWidget;

  /// 点击事件
  final VoidCallback? onTap;

  /// 是否自动识别图片类型（默认：true）
  final bool autoDetect;

  /// 构造函数（自动识别模式）
  const EasyImage(this.image,
      {super.key,
      this.style = const ImageStyle(),
      this.placeholder,
      this.errorWidget,
      this.onTap,
      this.autoDetect = true});

  /// 构造函数（手动指定图片源）
  const EasyImage.source(
      {super.key,
      required ImageSource source,
      this.style = const ImageStyle(),
      this.placeholder,
      this.errorWidget,
      this.onTap})
      : image = source,
        autoDetect = false;

  @override
  Widget build(BuildContext context) {
    // 处理图片源
    final ImageSource source = autoDetect
        ? ImageSource.auto(image)
        : image is ImageSource
            ? image as ImageSource
            : ImageSource.auto(image);

    // 加载图片
    return ImageLoader.loadImage(
      source,
      style,
      placeholder: placeholder,
      errorWidget: errorWidget,
      onTap: onTap,
    );
  }

  /// 快捷构造：网络图片
  static EasyImage network(String url,
      {Key? key,
      ImageStyle style = const ImageStyle(),
      Widget? placeholder,
      Widget? errorWidget,
      VoidCallback? onTap}) {
    return EasyImage.source(
        key: key,
        source: ImageSource.network(url),
        style: style,
        placeholder: placeholder,
        errorWidget: errorWidget,
        onTap: onTap);
  }

  /// 快捷构造：Asset图片
  static EasyImage asset(String assetPath,
      {Key? key,
      ImageStyle style = const ImageStyle(),
      Widget? placeholder,
      Widget? errorWidget,
      VoidCallback? onTap}) {
    return EasyImage.source(
        key: key,
        source: ImageSource.asset(assetPath),
        style: style,
        placeholder: placeholder,
        errorWidget: errorWidget,
        onTap: onTap);
  }

  /// 快捷构造：Base64图片
  static EasyImage base64(String base64String,
      {Key? key,
      ImageStyle style = const ImageStyle(),
      Widget? placeholder,
      Widget? errorWidget,
      VoidCallback? onTap}) {
    return EasyImage.source(
        key: key,
        source: ImageSource.base64(base64String),
        style: style,
        placeholder: placeholder,
        errorWidget: errorWidget,
        onTap: onTap);
  }

  /// 快捷构造：圆形图片
  static EasyImage circle(
    String image, {
    Key? key,
    double size = 40,
    ImageStyle style = const ImageStyle(),
    Widget? placeholder,
    Widget? errorWidget,
    VoidCallback? onTap,
  }) {
    return EasyImage(
      image,
      key: key,
      style: style.copyWith(width: size, height: size, isCircle: true),
      placeholder: placeholder,
      errorWidget: errorWidget,
      onTap: onTap,
    );
  }
}
