import 'package:r99/export.dart';

mixin SignUpPageControllerMixin on State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscurePassword = signal<bool>(true);
  final isSubmitting = signal<bool>(false);
  final errorMessage = signal<String?>(null);
  final successMessage = signal<String?>(null);

  Future<void> submitSignUp() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    isSubmitting.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      final signedIn = await SupabaseAuthService.signUpWithEmailPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      if (signedIn) {
        widget.onLoginSuccess();
        return;
      }

      successMessage.value =
          'Account created. Please check your email to confirm, then sign in.';
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    obscurePassword.dispose();
    isSubmitting.dispose();
    errorMessage.dispose();
    successMessage.dispose();
    super.dispose();
  }
}
