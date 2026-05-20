import 'package:r99/export.dart';

class CustomInputFieldText extends StatelessWidget {
  const CustomInputFieldText({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.keyboardType,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.validator,
    this.fillColor = AppColor.loginInputFill,
    this.borderRadius = 16,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.prefixIconColor,
    this.suffixIconColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String? value)? validator;
  final Color fillColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = enabledBorderColor ?? AppColor.borderLighter;
    final activeBorderColor = focusedBorderColor ?? AppColor.themeSeed;
    final invalidBorderColor = errorBorderColor ?? AppColor.danger;

    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: textStyle,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixIconColor: prefixIconColor,
        suffixIconColor: suffixIconColor,
        hintStyle: hintStyle,
        labelStyle: labelStyle,
        contentPadding: contentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: activeBorderColor, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: invalidBorderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: invalidBorderColor, width: 1.4),
        ),
        filled: true,
        fillColor: fillColor,
      ),
    );
  }
}
