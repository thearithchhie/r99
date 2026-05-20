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
                          SizedBox(
                            height: 320,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 126,
                                  height: 126,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: Assets.logo.logo.image(
                                      fit: BoxFit.cover,
                                    ),
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
                                const SizedBox(height: 6),
                                Text(
                                  'delivery interface',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColor.textOnDark.withValues(
                                      alpha: 0.78,
                                    ),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Member Login',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColor.textOnDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomInputFieldText(
                            controller: usernameController,
                            textInputAction: TextInputAction.next,
                            hintText: 'Username',
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
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
                            enabledBorderColor: AppColor.darkSurfaceBorder,
                            focusedBorderColor: AppColor.brandPrimary,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter username';
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
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 60,
                            child: FilledButton(
                              onPressed: submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColor.brandPrimary,
                                foregroundColor: AppColor.textOnDark,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    _fieldRadius,
                                  ),
                                ),
                                shadowColor: AppColor.brandPrimarySoft,
                              ),
                              child: const Text(
                                'SIGN IN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Forgot the password? ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColor.textMuted,
                                    ),
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
