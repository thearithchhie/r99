import 'package:r99/export.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with LoginPageControllerMixin {
  static const _fieldRadius = 999.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Watch((context) {
        return Container(
          decoration: const BoxDecoration(gradient: AppColor.appDarkBackgroundGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 126,
                                height: 126,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: Assets.logo.logo.image(fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'R99',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: AppColor.brandPrimary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          CustomInputFieldText(
                            controller: usernameController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            fillColor: AppColor.darkSurfaceAlt,
                            borderRadius: _fieldRadius,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                            textStyle: const TextStyle(
                              color: AppColor.textOnDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            hintStyle: const TextStyle(color: AppColor.textMuted, fontSize: 15),
                            prefixIconColor: AppColor.textMuted,
                            enabledBorderColor: AppColor.darkSurfaceBorder,
                            focusedBorderColor: AppColor.brandPrimary,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomInputFieldText(
                            controller: passwordController,
                            obscureText: obscurePassword.value,
                            onFieldSubmitted: (_) => submit(),
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: toggleObscurePassword,
                              icon: Icon(
                                obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              ),
                            ),
                            fillColor: AppColor.darkSurfaceAlt,
                            borderRadius: _fieldRadius,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                            textStyle: const TextStyle(
                              color: AppColor.textOnDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            hintStyle: const TextStyle(color: AppColor.textMuted, fontSize: 15),
                            prefixIconColor: AppColor.textMuted,
                            suffixIconColor: AppColor.textMuted,
                            enabledBorderColor: AppColor.darkSurfaceBorder,
                            focusedBorderColor: AppColor.brandPrimary,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          if (errorMessage.value != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColor.brandPrimarySoft,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColor.brandPrimary),
                              ),
                              child: Text(
                                errorMessage.value!,
                                style: const TextStyle(color: AppColor.textOnDark, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          SizedBox(
                            height: 60,
                            child: FilledButton(
                              onPressed: isSubmitting.value ? null : submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColor.brandPrimary,
                                foregroundColor: AppColor.textOnDark,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_fieldRadius)),
                                shadowColor: AppColor.brandPrimarySoft,
                              ),
                              child: isSubmitting.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColor.textOnDark),
                                    )
                                  : const Text(
                                      'SIGN IN',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: Column(
                              children: [
                                TextButton(
                                  onPressed: openSignUpPage,
                                  child: const Text('No account yet? Sign up first'),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Forgot the password? ',
                                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColor.textMuted),
                                      ),
                                      TextSpan(
                                        text: 'Click here',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: AppColor.textOnDark,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColor.textOnDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
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
