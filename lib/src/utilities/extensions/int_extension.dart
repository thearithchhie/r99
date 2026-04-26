import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:r99/src/utilities/extensions/dynamic_extension.dart';
import 'package:r99/src/utilities/helper/responsive_font_system.dart';

extension IntExtension on int {
  EdgeInsets pt() {
    return EdgeInsets.only(top: toDouble());
  }

  EdgeInsets pb() {
    return EdgeInsets.only(bottom: toDouble());
  }

  EdgeInsets pl() {
    return EdgeInsets.only(left: toDouble());
  }

  EdgeInsets pr() {
    return EdgeInsets.only(right: toDouble());
  }

  EdgeInsets px({double? y}) {
    return EdgeInsets.symmetric(horizontal: toDouble(), vertical: y ?? 0);
  }

  EdgeInsets py({double? x}) {
    return EdgeInsets.symmetric(vertical: toDouble(), horizontal: x ?? 0);
  }

  EdgeInsets p({double? l, double? r, double? t, double? b}) {
    return EdgeInsets.only(
      left: l ?? toDouble(),
      right: r ?? toDouble(),
      top: t ?? toDouble(),
      bottom: b ?? toDouble(),
    );
  }

  SizedBox sw() {
    return SizedBox(width: toDouble());
  }

  SizedBox sh() {
    return SizedBox(height: toDouble());
  }

  SizedBox s() {
    return SizedBox(height: toDouble(), width: toDouble());
  }

  BorderRadius r({double? tl, double? tr, double? bl, double? br}) {
    return BorderRadius.only(
      topLeft: Radius.circular(tl ?? toDouble()),
      topRight: Radius.circular(tr ?? toDouble()),
      bottomLeft: Radius.circular(bl ?? toDouble()),
      bottomRight: Radius.circular(br ?? toDouble()),
    );
  }

  BorderRadius rt({double? l, double? r}) {
    return BorderRadius.only(topLeft: Radius.circular(l ?? toDouble()), topRight: Radius.circular(r ?? toDouble()));
  }

  BorderRadius rb({double? l, double? r}) {
    return BorderRadius.only(
      bottomLeft: Radius.circular(l ?? toDouble()),
      bottomRight: Radius.circular(r ?? toDouble()),
    );
  }

  Radius radius() {
    return Radius.circular(toDouble());
  }

  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(this);
  }

  double toFontSize() {
    final size = toAppDouble();
    return defaultTargetPlatform == TargetPlatform.android
        ? (size * ResponsiveFontSystem.androidFontSizeMultiplier)
        : size;
  }

  double toResponsiveFontSize(BuildContext context, {bool respectAccessibility = true}) {
    return ResponsiveFontSystem.getResponsiveFontSize(context, toDouble(), respectAccessibility: respectAccessibility);
  }
}
