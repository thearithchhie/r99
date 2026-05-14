import 'package:r99/export.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with LoginPageControllerMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Watch((context) {
        return Container(
          decoration: const BoxDecoration(gradient: AppColor.loginBackgroundGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 0,
                    color: AppColor.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: const BorderSide(color: AppColor.cardBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CircleAvatar(
                              radius: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(Assets.logo.logo.path, fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Welcome Back',
                                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomInputFieldText(
                              controller: usernameController,
                              textInputAction: TextInputAction.next,
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person_outline),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            CustomInputFieldText(
                              controller: passwordController,
                              obscureText: obscurePassword.value,
                              onFieldSubmitted: (_) => submit(),
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: toggleObscurePassword,
                                icon: Icon(
                                  obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              height: 54,
                              child: FilledButton(
                                onPressed: submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColor.themeSeed,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
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
          ),
        );
      }),
    );
  }
}
