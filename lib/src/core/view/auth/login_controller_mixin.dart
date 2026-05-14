import 'package:r99/export.dart';

mixin LoginPageControllerMixin on State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = signal<bool>(true);

  void submit() {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onLoginSuccess();
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    obscurePassword.dispose();
    super.dispose();
  }
}
