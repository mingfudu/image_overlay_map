library bubble_widget;

import 'dart:math';

import 'package:flutter/material.dart';

/// 气泡组件
///
/// @author Peter https://pub.dev/packages/bubble_widget/versions
/// move to null safety by @mingfudu
///
/// Create on 2020/09/01
class BubbleWidget extends StatelessWidget {
  final Widget child;

  /// child相对于气泡体的 padding
  final EdgeInsetsGeometry? padding;

  /// 气泡样式， [BubbleStyle.stroke] 为描边式； [BubbleStyle.fill]为填充式
  final BubbleStyle style;

  /// 背景色
  final Color color;

  /// 描边颜色，[style] 为 [BubbleStyle.stroke] 时有效
  final Color strokeColor;

  /// 描边宽度，[style] 为 [BubbleStyle.stroke] 时有效
  final double strokeWidth;

  /// 气泡体圆角半径
  final double borderRadius;

  /// 气泡尖角底部宽度
  final double arrowWidth;

  /// 气泡尖角高度
  final double arrowHeight;

  /// 气泡尖角相对于气泡体的位置
  final ArrowDirection direction;

  /// 气泡尖角相对位置系数，0.0~1.0，左上角起算
  final double positionRatio;

  /// @see [Material]的[elevation]定义，z轴高度 </br>
  /// The z-coordinate at which to place this material relative to its parent.
  final double? elevation;

  const BubbleWidget(
      {Key? key,
      required this.child,
      this.padding,
      this.color = Colors.transparent,
      this.arrowWidth = 8.0,
      this.arrowHeight = 5.0,
      this.borderRadius = 10.0,
      this.direction = ArrowDirection.bottom,
      this.positionRatio = 0.5,
      this.style = BubbleStyle.fill,
      this.strokeColor = Colors.transparent,
      this.strokeWidth = 0.5,
      this.elevation})
      : super(key: key);

  get _arrowMargin {
    var edgeInsets;
    switch (direction) {
      case ArrowDirection.left:
        edgeInsets = EdgeInsets.only(left: arrowHeight);
        break;
      case ArrowDirection.top:
        edgeInsets = EdgeInsets.only(top: arrowHeight);
        break;
      case ArrowDirection.right:
        edgeInsets = EdgeInsets.only(right: arrowHeight);
        break;
      default:
        edgeInsets = EdgeInsets.only(bottom: arrowHeight);
        break;
    }
    return edgeInsets;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: color,
        // 透明填充背景时，无需投影
        shadowColor: color == Colors.transparent
            ? Colors.transparent
            : const Color(0xFF000000),
        elevation: elevation ?? (color == Colors.transparent ? 0 : 5),
        shape: BubbleShape(
            style: style,
            strokeColor: strokeColor,
            strokeWidth: strokeWidth,
            direction: direction,
            positionRatio: positionRatio,
            arrowHeight: arrowHeight,
            arrowWidth: arrowWidth,
            borderRadius: borderRadius),
        child: Container(margin: _arrowMargin, padding: padding, child: child));
  }
}

enum ArrowDirection { left, top, right, bottom }

enum BubbleStyle { stroke, fill }

/// 参考资料：https://juejin.im/post/6844904082629459982
class BubbleShape extends ShapeBorder {
  final BubbleStyle style;
  final Color strokeColor;
  final double strokeWidth;

  final ArrowDirection direction;

  /// 气泡尖角高度
  final double arrowHeight;

  /// 气泡尖角宽度（尖角底部大小）
  final double arrowWidth;

  /// 气泡圆角半径
  final double borderRadius;
  final double positionRatio;

  BubbleShape(
      {this.style = BubbleStyle.fill,
      this.strokeColor = Colors.transparent,
      this.strokeWidth = 0.5,
      this.direction = ArrowDirection.bottom,
      this.positionRatio = 0.5,
      this.arrowHeight = 5.0,
      this.arrowWidth = 8.0,
      this.borderRadius = 10.0})
      : assert(positionRatio >= 0 && positionRatio <= 1, '气泡尖角位置系数必须是0-1范围');

  /// 修正不合规的尺寸: [arrowHeight]
  getArrowHeightFit(Rect rect) {
    if (arrowHeight < 0) {
      return 0.0;
    }
    if (direction == ArrowDirection.left || direction == ArrowDirection.right) {
      if (arrowHeight > rect.width) {
        return rect.width;
      }
    } else {
      if (arrowHeight > rect.height) {
        return rect.height;
      }
    }
    return arrowHeight;
  }

  /// 修正不合规的尺寸: [borderRadius]
  getBorderRadiusFit(Rect rect) {
    if (borderRadius < 0) {
      return 0.0;
    }
    var maxRadius;
    var arrowHeightFit = getArrowHeightFit(rect);
    if (direction == ArrowDirection.left || direction == ArrowDirection.right) {
      maxRadius = 0.5 * min(rect.width - arrowHeightFit, rect.height);
    } else {
      maxRadius = 0.5 * min(rect.width, rect.height - arrowHeightFit);
    }
    if (borderRadius > maxRadius) {
      return maxRadius;
    }
    return borderRadius;
  }

  /// 修正不合规的尺寸: [arrowWidth]
  getArrowWidthFit(Rect rect) {
    if (arrowWidth < 0) {
      return 0.0;
    }
    var borderRadiusFit = getBorderRadiusFit(rect);
    var maxWidth;
    if (direction == ArrowDirection.left || direction == ArrowDirection.right) {
      maxWidth = rect.height - 2 * borderRadiusFit;
    } else {
      maxWidth = rect.width - 2 * borderRadiusFit;
    }
    if (arrowWidth > maxWidth) {
      return maxWidth;
    }
    return arrowWidth;
  }

  /// 修正不合规的尺寸: [positionRatio]
  getPositionRatioFit(Rect rect) {
    var borderRadiusFit = getBorderRadiusFit(rect);
    var arrowWidthFit = getArrowWidthFit(rect);
    var minPositionRatio;
    var maxPositionRatio;
    if (direction == ArrowDirection.left || direction == ArrowDirection.right) {
      minPositionRatio = (borderRadiusFit + 0.5 * arrowWidthFit) / rect.height;
      maxPositionRatio =
          (rect.height - borderRadiusFit - 0.5 * arrowWidthFit) / rect.height;
    } else {
      minPositionRatio = (borderRadiusFit + 0.5 * arrowWidthFit) / rect.width;
      maxPositionRatio =
          (rect.width - borderRadiusFit - 0.5 * arrowWidthFit) / rect.width;
    }
    if (positionRatio < minPositionRatio) {
      return minPositionRatio;
    }
    if (positionRatio > maxPositionRatio) {
      return maxPositionRatio;
    }
    return positionRatio;
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  /// 返回一个Path对象，也就是形状的裁剪
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    var path = Path();
    _addBubblePath(path, rect);
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (style == BubbleStyle.stroke) {
      var paint = Paint()
        ..color = strokeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      var path = Path();
      _addBubblePath(path, rect);
      canvas.drawPath(path, paint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return Border();
  }

  /// 添加气泡路径
  _addBubblePath(Path path, Rect rect) {
    var w = rect.width;
    var h = rect.height;
    var borderRadiusFit = getBorderRadiusFit(rect);
    var positionRatioFit = getPositionRatioFit(rect);
    var arrowHeightFit = getArrowHeightFit(rect);
    var arrowWidthFit = getArrowWidthFit(rect);

    var xOffset = direction == ArrowDirection.left ? arrowHeightFit : 0.0;
    var yOffSet = direction == ArrowDirection.top ? arrowHeightFit : 0.0;
    var xOffsetEnd = direction == ArrowDirection.right ? arrowHeightFit : 0.0;
    var yOffSetEnd = direction == ArrowDirection.bottom ? arrowHeightFit : 0.0;

    //尖角底部中心x坐标
    var xArrowCenter = positionRatioFit * w;
    //尖角底部中心y坐标
    var yArrowCenter = positionRatioFit * h;
    path
      ..moveTo(xOffset, yOffSet + borderRadiusFit)
      // 添加左上圆角
      ..arcTo(
          Rect.fromCircle(
              center:
                  Offset(xOffset + borderRadiusFit, yOffSet + borderRadiusFit),
              radius: borderRadiusFit),
          pi,
          0.5 * pi,
          false);
    // 添加上边
    if (direction == ArrowDirection.top) {
      path
        ..lineTo(xArrowCenter - 0.5 * arrowWidthFit, yOffSet)
        ..lineTo(xArrowCenter, 0.0)
        ..lineTo(xArrowCenter + 0.5 * arrowWidthFit, yOffSet);
    }
    path.lineTo(w - xOffsetEnd - borderRadiusFit, yOffSet);
    // 添加右上角
    path.arcTo(
        Rect.fromCircle(
            center: Offset(
                w - xOffsetEnd - borderRadiusFit, yOffSet + borderRadiusFit),
            radius: borderRadiusFit),
        -0.5 * pi,
        0.5 * pi,
        false);
    // 添加右边
    if (direction == ArrowDirection.right) {
      path
        ..lineTo(w - xOffsetEnd, yArrowCenter - 0.5 * arrowWidthFit)
        ..lineTo(w, yArrowCenter)
        ..lineTo(w - xOffsetEnd, yArrowCenter + 0.5 * arrowWidthFit);
    }
    path.lineTo(w - xOffsetEnd, h - yOffSetEnd - borderRadiusFit);
    // 添加右下角
    path.arcTo(
        Rect.fromCircle(
            center: Offset(w - xOffsetEnd - borderRadiusFit,
                h - yOffSetEnd - borderRadiusFit),
            radius: borderRadiusFit),
        0,
        0.5 * pi,
        false);
    // 添加下边
    if (direction == ArrowDirection.bottom) {
      path
        ..lineTo(xArrowCenter + 0.5 * arrowWidthFit, h - yOffSetEnd)
        ..lineTo(xArrowCenter, h)
        ..lineTo(xArrowCenter - 0.5 * arrowWidthFit, h - yOffSetEnd);
    }
    path.lineTo(xOffset + borderRadiusFit, h - yOffSetEnd);
    // 添加左下角
    path.arcTo(
        Rect.fromCircle(
            center: Offset(
                xOffset + borderRadiusFit, h - yOffSetEnd - borderRadiusFit),
            radius: borderRadiusFit),
        0.5 * pi,
        0.5 * pi,
        false);
    //添加左边
    if (direction == ArrowDirection.left) {
      path
        ..lineTo(xOffset, yArrowCenter + 0.5 * arrowWidthFit)
        ..lineTo(0.0, yArrowCenter)
        ..lineTo(xOffset, yArrowCenter - 0.5 * arrowWidthFit);
    }
    // 直接闪环即表示添加左边
    path.close();
  }
}
