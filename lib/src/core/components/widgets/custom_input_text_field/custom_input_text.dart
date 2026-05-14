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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        filled: true,
        fillColor: fillColor,
      ),
    );
  }
}
