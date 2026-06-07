import 'package:r99/export.dart';

mixin LoginPageControllerMixin on State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = signal<bool>(true);
  final isSubmitting = signal<bool>(false);
  final errorMessage = signal<String?>(null);

  Future<void> submit() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      await SupabaseAuthService.signInWithEmailPassword(
        email: usernameController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      widget.onLoginSuccess();
    } catch (error) {
      if (!mounted) return;
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        isSubmitting.value = false;
      }
    }
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void openSignUpPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpPage(onLoginSuccess: widget.onLoginSuccess),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    obscurePassword.dispose();
    isSubmitting.dispose();
    errorMessage.dispose();
    super.dispose();
  }
}
