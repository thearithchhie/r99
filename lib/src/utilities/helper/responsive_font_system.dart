import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ResponsiveFontSystem {
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  static const double _minScaleFactor = 0.85;
  static const double _maxScaleFactor = 1.15;

  static double androidFontSizeMultiplier = 1;

  static double? _cachedScaleFactor;
  static Size? _cachedScreenSize;

  static double _getScaleFactor(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_cachedScreenSize == size && _cachedScaleFactor != null) {
      return _cachedScaleFactor!;
    }

    final shortestSide = size.shortestSide;
    final scaleFactor = shortestSide / _designWidth;

    final clampedFactor = scaleFactor.clamp(_minScaleFactor, _maxScaleFactor);

    _cachedScreenSize = size;
    _cachedScaleFactor = clampedFactor;

    return clampedFactor;
  }

  static double getResponsiveFontSize(
    BuildContext context,
    double baseSize, {
    bool respectAccessibility = true,
  }) {
    final scaleFactor = _getScaleFactor(context);

    double fontSize = baseSize * scaleFactor;

    if (defaultTargetPlatform == TargetPlatform.android) {
      fontSize *= androidFontSizeMultiplier;
    }

    if (respectAccessibility) {
      final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);

      final clampedTextScale = textScaleFactor.clamp(0.8, 1.3);
      fontSize *= clampedTextScale;
    }

    return fontSize;
  }

  static double getLineHeight(double fontSize) {
    if (fontSize <= 12) {
      return 1.5;
    } else if (fontSize <= 16) {
      return 1.4;
    } else if (fontSize <= 20) {
      return 1.35;
    } else if (fontSize <= 24) {
      return 1.3;
    } else {
      return 1.25;
    }
  }

  static double getLetterSpacing(double fontSize, FontWeight weight) {
    final weightMultiplier = weight.value >= FontWeight.w600.value ? 0.02 : 0.0;

    if (fontSize <= 12) {
      return 0.1 + weightMultiplier;
    } else if (fontSize <= 16) {
      return 0.15 + weightMultiplier;
    } else if (fontSize <= 20) {
      return 0.2 + weightMultiplier;
    } else {
      return 0.25 + weightMultiplier;
    }
  }

  static void resetCache() {
    _cachedScaleFactor = null;
    _cachedScreenSize = null;
  }

  static double getScaleFactorOnly(BuildContext context) {
    return _getScaleFactor(context);
  }

  static double designWidth = _designWidth;
  static double designHeight = _designHeight;
  static double minScale = _minScaleFactor;
  static double maxScale = _maxScaleFactor;
}
