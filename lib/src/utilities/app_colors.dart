import 'package:flutter/material.dart';

class AppColor {
  const AppColor._();

  static const Color primary = Color(0xff2E55F3);
  static const Color primary50 = Color(0xff2E55F3);
  static const Color secondary = Color(0xff2E55F3);
  static const Color mainBackground = Color(0xFFF7F7F7);
  static const Color disabled = Color(0xff2644BD);

  static const Color black = Color(0xff000000);
  static const Color white = Color(0xffFFFFFF);
  static const Color grey = Color(0xffDBDBDB);
  static const Color greyLight = Color(0xFFEAEAEA);
  static const Color coolBlueGray = Color(0xFF90A1B9);
  static const Color danger = Color(0xFFFF4141);
  static const Color waring = Color(0xffFF8800);
  static const Color green = Color(0xff3AC573);
  static const Color yellow = Color(0xffFFCC00);

  //Magnolia
  static const Color pr50 = Color(0xfff0f5fe);
  static const Color pr100 = Color(0xffdde8fc);
  static const Color pr200 = Color(0xffc3d8fa);
  static const Color pr300 = Color(0xff9abff6);
  static const Color pr400 = Color(0xff6a9ef0);
  static const Color pr500 = Color(0xff477bea);
  static const Color pr600 = Color(0xff325dde);
  static const Color pr700 = Color(0xff2644bd);
  static const Color pr800 = Color(0xff273da6);
  static const Color pr900 = Color(0xff253783);
  static const Color pr950 = Color(0xff1b2450);

  static const Color neutral50 = Color(0xfff6f6f6);
  static const Color neutral100 = Color(0xffe7e7e7);
  static const Color neutral150 = Color(0xffF1F3F5);
  static const Color neutral175 = Color(0xffE2E8F0);
  static const Color neutral185 = Color(0xFFCDDBE4);
  static const Color neutral200 = Color(0xffd1d1d1);
  static const Color neutral300 = Color(0xffb0b0b0);
  static const Color neutral400 = Color(0xff888888);
  static const Color neutral500 = Color(0xff6d6d6d);
  static const Color neutral600 = Color(0xff5d5d5d);
  static const Color neutral700 = Color(0xff4f4f4f);
  static const Color neutral800 = Color(0xff454545);
  static const Color neutral900 = Color(0xff3d3d3d);
  static const Color neutral950 = Color(0xff0a0a0a);
  static const Color neutral9501 = Color(0xffECEEF0);
  static const Color neutral9502 = Color(0xff90A1B9);

  static const Color themeSeed = Color(0xFF1F5E5B);
  static const Color appScaffoldBackground = Color(0xFFF5F2E8);
  static const Color loginGradientStart = Color(0xFFF5F2E8);
  static const Color loginGradientEnd = Color(0xFFE0ECE8);
  static const Color loginInputFill = Color(0xFFFAF8F3);
  static const Color cardBorder = Color(0xFFD7D2C8);
  static const LinearGradient loginBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [loginGradientStart, loginGradientEnd],
  );

  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  static const Color surfaceMuted = Color(0xFFF9F9F9);
  static const Color surfacePreview = Color(0xFFF5F5F5);
  static const Color borderLight = Color(0xFFBDBDBD);
  static const Color borderLighter = Color(0xFFD5D5D5);
  static const Color borderSubtle = Color(0xFFD9D9D9);
  static const Color overlayScrim = Color(0x99000000);
  static const Color errorText = Colors.redAccent;

  static const Color brandPrimary = Color(0xFFD71920);
  static const Color brandPrimarySoft = Color(0x33D71920);
  static const Color appDarkBackground = Color(0xFF111111);
  static const Color appDarkBackgroundAlt = Color(0xFF080808);
  static const Color darkSurface = Color(0xFF151515);
  static const Color darkSurfaceAlt = Color(0xFF1A1A1A);
  static const Color darkSurfaceBorder = Color(0xFF3A3A3A);
  static const Color darkSurfaceBorderSoft = Color(0xFF1E1E1E);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFBFC0C0);

  static const LinearGradient appDarkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [appDarkBackground, appDarkBackgroundAlt],
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkSurface, appDarkBackgroundAlt],
  );

  static Color colorHex(String v) {
    v = v.replaceAll("#", "");
    return Color(int.parse("0xFF$v"));
  }
}
