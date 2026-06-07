// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsLogoGen {
  const $AssetsLogoGen();

  /// File path: assets/logo/logo.jpg
  AssetGenImage get logo => const AssetGenImage('assets/logo/logo.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [logo];
}

class $AssetsPngsGen {
  const $AssetsPngsGen();

  /// File path: assets/pngs/facebook-svgrepo-com.png
  AssetGenImage get facebookSvgrepoCom =>
      const AssetGenImage('assets/pngs/facebook-svgrepo-com.png');

  /// File path: assets/pngs/location-pin-svgrepo-com.png
  AssetGenImage get locationPinSvgrepoCom =>
      const AssetGenImage('assets/pngs/location-pin-svgrepo-com.png');

  /// File path: assets/pngs/person-svgrepo-com.png
  AssetGenImage get personSvgrepoCom =>
      const AssetGenImage('assets/pngs/person-svgrepo-com.png');

  /// File path: assets/pngs/phone-call-answer-svgrepo-com.png
  AssetGenImage get phoneCallAnswerSvgrepoCom =>
      const AssetGenImage('assets/pngs/phone-call-answer-svgrepo-com.png');

  /// File path: assets/pngs/truck-speed-svgrepo-com.png
  AssetGenImage get truckSpeedSvgrepoCom =>
      const AssetGenImage('assets/pngs/truck-speed-svgrepo-com.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    facebookSvgrepoCom,
    locationPinSvgrepoCom,
    personSvgrepoCom,
    phoneCallAnswerSvgrepoCom,
    truckSpeedSvgrepoCom,
  ];
}

class $AssetsTessdataGen {
  const $AssetsTessdataGen();

  /// File path: assets/tessdata/eng.traineddata
  String get eng => 'assets/tessdata/eng.traineddata';

  /// File path: assets/tessdata/khm.traineddata
  String get khm => 'assets/tessdata/khm.traineddata';

  /// List of all assets
  List<String> get values => [eng, khm];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const $AssetsLogoGen logo = $AssetsLogoGen();
  static const $AssetsPngsGen pngs = $AssetsPngsGen();
  static const $AssetsTessdataGen tessdata = $AssetsTessdataGen();
  static const String tessdataConfig = 'assets/tessdata_config.json';

  /// List of all assets
  static List<String> get values => [aEnv, tessdataConfig];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
