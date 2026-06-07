import 'package:r99/export.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SignUpPageControllerMixin {
  static const _fieldRadius = 999.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Watch((context) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColor.appDarkBackgroundGradient,
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),
                          SizedBox(
                            width: 104,
                            height: 104,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: Assets.logo.logo.image(
                                  width: 104,
                                  height: 104,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColor.textOnDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign up first, then use your account to login.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColor.textMuted,
                            ),
                          ),
                          const SizedBox(height: 28),
                          CustomInputFieldText(
                            controller: emailController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            fillColor: AppColor.darkSurfaceAlt,
                            borderRadius: _fieldRadius,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 22,
                            ),
                            textStyle: const TextStyle(
                              color: AppColor.textOnDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            hintStyle: const TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 15,
                            ),
                            prefixIconColor: AppColor.textMuted,
                            enabledBorderColor: AppColor.darkSurfaceBorder,
                            focusedBorderColor: AppColor.brandPrimary,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomInputFieldText(
                            controller: passwordController,
                            textInputAction: TextInputAction.next,
                            obscureText: obscurePassword.value,
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: toggleObscurePassword,
                              icon: Icon(
                                obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            fillColor: AppColor.darkSurfaceAlt,
                            borderRadius: _fieldRadius,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 22,
                            ),
                            textStyle: const TextStyle(
                              color: AppColor.textOnDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            hintStyle: const TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 15,
                            ),
                            prefixIconColor: AppColor.textMuted,
                            suffixIconColor: AppColor.textMuted,
                            enabledBorderColor: AppColor.darkSurfaceBorder,
                            focusedBorderColor: AppColor.brandPrimary,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomInputFieldText(
                            controller: confirmPasswordController,
                            obscureText: obscurePassword.value,
                            onFieldSubmitted: (_) => submitSignUp(),
                            hintText: 'Confirm password',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            fillColor: AppColor.darkSurfaceAlt,
                            borderRadius: _fieldRadius,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 22,
                            ),
                            textStyle: const TextStyle(
                              color: AppColor.textOnDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            hintStyle: const TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 15,
                            ),
                            prefixIconColor: AppColor.textMuted,
                            enabledBorderColor: AppColor.darkSurfaceBorder,
                            focusedBorderColor: AppColor.brandPrimary,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          if (errorMessage.value != null) ...[
                            _AuthMessageBox(
                              message: errorMessage.value!,
                              isSuccess: false,
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (successMessage.value != null) ...[
                            _AuthMessageBox(
                              message: successMessage.value!,
                              isSuccess: true,
                            ),
                            const SizedBox(height: 16),
                          ],
                          SizedBox(
                            height: 60,
                            child: FilledButton(
                              onPressed: isSubmitting.value
                                  ? null
                                  : submitSignUp,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColor.brandPrimary,
                                foregroundColor: AppColor.textOnDark,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    _fieldRadius,
                                  ),
                                ),
                              ),
                              child: isSubmitting.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: AppColor.textOnDark,
                                      ),
                                    )
                                  : const Text(
                                      'SIGN UP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Already have account? Sign in'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _AuthMessageBox extends StatelessWidget {
  const _AuthMessageBox({required this.message, required this.isSuccess});

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSuccess ? AppColor.darkSurfaceAlt : AppColor.brandPrimarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuccess ? AppColor.textMuted : AppColor.brandPrimary,
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColor.textOnDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
