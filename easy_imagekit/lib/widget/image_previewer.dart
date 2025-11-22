import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 原生图片预览组件
class ImagePreviewer extends StatefulWidget {
  /// 图片列表（支持网络/Asset/Base64/本地文件）
  final List<dynamic> images;

  /// 初始显示索引
  final int initialIndex;

  /// 是否支持循环滑动（多图时）
  final bool loop;

  /// 背景色
  final Color backgroundColor;

  /// 关闭按钮颜色
  final Color closeBtnColor;

  /// 最小缩放比例
  final double minScale;

  /// 最大缩放比例
  final double maxScale;

  /// 滑动阈值（超过该距离视为滑动，不触发关闭）
  final double slideThreshold;

  /// 双击间隔
  final Duration doubleTapDuration;

  /// 多页自定义底部组件列表
  final List<Widget?>? customBottomWidgets;

  /// 自定义底部区域内边距
  final EdgeInsetsGeometry customBottomPadding;

  /// 底部区域与屏幕底部的间距（默认20px）
  final double bottomMargin;

  /// 底部区域与图片底部的间距（默认16px，控制底部组件离图片的距离）
  final double bottomToImageSpacing;

  const ImagePreviewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.loop = true,
    this.backgroundColor = Colors.black,
    this.closeBtnColor = Colors.white,
    this.minScale = 0.8,
    this.maxScale = 1.5,
    this.slideThreshold = 10.0,
    this.doubleTapDuration = const Duration(milliseconds: 300),
    this.customBottomWidgets,
    this.customBottomPadding = EdgeInsets.zero,
    this.bottomMargin = 20.0,
    this.bottomToImageSpacing = 16.0,
  });

  @override
  State<ImagePreviewer> createState() => _ImagePreviewerState();
}

class _ImagePreviewerState extends State<ImagePreviewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0; // 当前真实页码
  late TransformationController _transformationController;
  AnimationController? _animationController;
  Animation<Matrix4>? _animation;
  Timer? _doubleTapTimer;
  bool _isDoubleTap = false;
  Offset? _tapDownPosition;
  bool _isValidTap = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(
        initialPage: widget.loop ? _currentIndex + 1 : _currentIndex);

    if (widget.loop && widget.images.length > 1) {
      _pageController.addListener(_handlePageScroll);
    }

    _transformationController = TransformationController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    _transformationController.dispose();
    _animationController?.dispose();
    _doubleTapTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// 处理PageView滚动，更新当前索引
  void _handlePageScroll() {
    final currentPage = _pageController.page ?? 0;
    final imageCount = widget.images.length;

    if (imageCount <= 1 || !widget.loop) return;

    if (currentPage >= imageCount + 1) {
      _pageController.jumpToPage(1);
    } else if (currentPage <= 0) {
      _pageController.jumpToPage(imageCount);
    } else {
      final realIndex = (currentPage - 1).round();
      if (realIndex != _currentIndex) {
        setState(() => _currentIndex = realIndex);
        _resetImage();
      }
    }
  }

  /// 根据索引获取对应的自定义组件
  Widget? _getCustomWidgetByIndex(int index) {
    if (widget.customBottomWidgets == null) return null;
    final customWidgets = widget.customBottomWidgets!;
    if (customWidgets.length != widget.images.length) return null;
    return customWidgets[index];
  }

  /// 处理图片按下
  void _handleTapDown(TapDownDetails details) {
    _tapDownPosition = details.localPosition;
    _isValidTap = true;

    if (_doubleTapTimer == null) {
      _doubleTapTimer = Timer(widget.doubleTapDuration, () {
        _doubleTapTimer = null;
        if (!_isDoubleTap && _isValidTap) {
          Navigator.pop(context);
        }
        _isDoubleTap = false;
      });
    } else {
      _doubleTapTimer?.cancel();
      _doubleTapTimer = null;
      _isDoubleTap = true;
      _isValidTap = false;

      final currentScale = _transformationController.value.getMaxScaleOnAxis();
      if (currentScale < widget.maxScale / 2) {
        _scaleImage(details.localPosition, widget.maxScale / 2);
      } else {
        _resetImage();
      }
    }
  }

  /// 处理图片拖动
  void _handlePanUpdate(DragUpdateDetails details) {
    if (_tapDownPosition == null) return;

    final dx = details.localPosition.dx - _tapDownPosition!.dx;
    final dy = details.localPosition.dy - _tapDownPosition!.dy;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance > widget.slideThreshold) {
      _isValidTap = false;
    }
  }

  /// 处理手势结束
  void _handlePanEnd(DragEndDetails details) {
    _tapDownPosition = null;
  }

  /// 处理单击抬起
  void _handleTapUp(TapUpDetails details) {}

  /// 处理单击取消
  void _handleTapCancel() {
    _isValidTap = false;
  }

  /// 缩放图片
  void _scaleImage(Offset tapPosition, double targetScale) {
    final focalPoint =
        Matrix4.translationValues(-tapPosition.dx, -tapPosition.dy, 0.0);
    final scale = Matrix4.diagonal3Values(targetScale, targetScale, 1.0);
    final translation =
        Matrix4.translationValues(tapPosition.dx, tapPosition.dy, 0.0);

    _animation = Matrix4Tween(
            begin: _transformationController.value,
            end: focalPoint * scale * translation)
        .animate(CurvedAnimation(
            parent: _animationController!, curve: Curves.easeOut));

    _animation!.addListener(() {
      _transformationController.value = _animation!.value;
    });

    _animationController!.forward(from: 0);
  }

  /// 重置图片
  void _resetImage() {
    _animation = Matrix4Tween(
            begin: _transformationController.value, end: Matrix4.identity())
        .animate(CurvedAnimation(
            parent: _animationController!, curve: Curves.easeOut));

    _animation!.addListener(() {
      _transformationController.value = _animation!.value;
    });

    _animationController!.forward(from: 0);
  }

  /// 限制缩放和平移
  /// 限制缩放范围和平移边界
  Matrix4 _clampMatrix(Matrix4 matrix) {
    // 1. 安全获取缩放比例（避免NaN或无穷大）
    final scale = matrix.getMaxScaleOnAxis();
    if (scale.isNaN || scale.isInfinite || scale <= 0) {
      return Matrix4.identity(); // 异常缩放时重置
    }

    // 2. 限制缩放范围（增加精度修正，避免极端小数）
    final clampedScale = double.tryParse(
            scale.clamp(widget.minScale, widget.maxScale).toStringAsFixed(2)) ??
        1;
    final scaleRatio = clampedScale / scale;

    // 3. 应用缩放修正（避免缩放异常）
    matrix = matrix.scaled(scaleRatio, scaleRatio);

    // 4. 安全计算图片尺寸和最大平移偏移（处理负数情况）
    final viewSize = MediaQuery.of(context).size;
    if (viewSize.width <= 0 || viewSize.height <= 0) {
      return matrix; // 屏幕尺寸异常时直接返回
    }

    final imageWidth = viewSize.width / clampedScale;
    final imageHeight = viewSize.height / clampedScale;

    // 最大平移偏移：图片超出屏幕的部分的一半（负数时设为0，避免反向偏移）
    final maxOffsetX = double.tryParse(
            max(0.0, (imageWidth - viewSize.width) / 2).toStringAsFixed(2)) ??
        0;
    final maxOffsetY = double.tryParse(
            max(0.0, (imageHeight - viewSize.height) / 2).toStringAsFixed(2)) ??
        0;

    // 5. 安全获取当前平移值并限制边界
    final currentTranslation = matrix.getTranslation();
    final offsetX = currentTranslation.x.clamp(-maxOffsetX, maxOffsetX);
    final offsetY = currentTranslation.y.clamp(-maxOffsetY, maxOffsetY);

    // 6. 应用修正后的平移值
    return matrix..setTranslationRaw(offsetX, offsetY, 0.0);
  }

  /// 获取图片Provider
  ImageProvider _getImageProvider(dynamic image) {
    if (image is String) {
      if (image.startsWith(RegExp(r'^https?://', caseSensitive: false))) {
        return NetworkImage(image);
      } else if (image
          .startsWith(RegExp(r'^data:image/', caseSensitive: false))) {
        final bytes = base64Decode(image.split(',').last);
        return MemoryImage(bytes);
      } else if (image.startsWith('/') || image.startsWith('file://')) {
        return FileImage(File(image.replaceFirst('file://', '')));
      } else {
        return AssetImage(image);
      }
    } else if (image is Uint8List) {
      return MemoryImage(image);
    } else if (image is ImageProvider) {
      return image;
    }
    throw UnimplementedError('不支持的图片类型：${image.runtimeType}');
  }

  /// 构建单个PageView Item（图片居中 + 底部组件在图片上层）
  Widget _buildPageItem(int displayIndex) {
    final imageProvider = _getImageProvider(widget.images[displayIndex]);
    final customWidget = _getCustomWidgetByIndex(displayIndex);
    final hasCustomWidget = customWidget != null;
    final imageCount = widget.images.length;

    return Stack(
      alignment: Alignment.center, // 整个item的子组件都垂直+水平居中
      children: [
        // 1. 图片区域（居中显示，占满可用空间，在最下层）
        Expanded(
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              onInteractionEnd: (details) {
                _transformationController.value =
                    _clampMatrix(_transformationController.value);
              },
              child: Center(
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.contain, // 保持图片比例，居中显示
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                        child: CircularProgressIndicator(
                            color: widget.closeBtnColor.withOpacity(0.7),
                            strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                        child: Icon(Icons.broken_image,
                            color: widget.closeBtnColor.withOpacity(0.7),
                            size: 48));
                  },
                ),
              ),
            ),
          ),
        ),
        // 2. 底部区域（绝对定位在图片上层，下方居中）
        Positioned(
          bottom: widget.bottomMargin, // 离屏幕底部的距离
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 自定义组件（在图片上层）
              if (hasCustomWidget)
                Container(
                    width: double.infinity,
                    margin: EdgeInsets.zero,
                    padding: widget.customBottomPadding,
                    child: customWidget),
              // 页码指示器（在自定义组件下方，或直接在图片上层）
              if (imageCount > 1)
                Padding(
                  padding: EdgeInsets.only(
                      top: hasCustomWidget ? 8.0 : widget.bottomToImageSpacing),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(blurRadius: 4, color: Colors.black26)
                      ],
                    ),
                    child: Text('${_currentIndex + 1}/$imageCount',
                        style: TextStyle(
                            color: widget.closeBtnColor, fontSize: 14)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = widget.images.length;
    final needLoop = imageCount > 1 && widget.loop;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            behavior: HitTestBehavior.translucent,
            child: PageView.builder(
              controller: _pageController,
              itemCount: needLoop ? imageCount + 2 : imageCount,
              physics: needLoop
                  ? const ClampingScrollPhysics()
                  : const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                if (!needLoop) {
                  final realIndex = index;
                  if (realIndex != _currentIndex) {
                    setState(() => _currentIndex = realIndex);
                    _resetImage();
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                  }
                }
              },
              // 每个item都是「居中图片 + 上层底部组件」的组合
              itemBuilder: (context, index) {
                final displayIndex =
                    needLoop ? _getLoopDisplayIndex(index, imageCount) : index;
                return _buildPageItem(displayIndex);
              },
            ),
          ),
          // 关闭按钮（固定在右上角，在最上层）
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 4, color: Colors.black26)
                  ],
                ),
                child: Icon(Icons.close, color: widget.closeBtnColor, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 循环模式下获取真实图片索引
  int _getLoopDisplayIndex(int pageIndex, int imageCount) {
    if (pageIndex == 0) {
      return imageCount - 1;
    } else if (pageIndex == imageCount + 1) {
      return 0;
    } else {
      return pageIndex - 1;
    }
  }
}

// 辅助扩展：从Matrix4获取缩放比例
extension Matrix4Extension on Matrix4 {
  double getMaxScaleOnAxis() {
    // 计算X/Y轴缩放比例（避免NaN）
    final scaleX =
        sqrt((row0.x * row0.x + row0.y * row0.y + row0.z * row0.z).abs());
    final scaleY =
        sqrt((row1.x * row1.x + row1.y * row1.y + row1.z * row1.z).abs());

    // 限制最小缩放比例为0.01，避免0或负数
    return max(0.01, max(scaleX, scaleY));
  }
}
